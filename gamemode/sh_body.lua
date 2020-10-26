local MAX_DISTANCE = 90

if (SERVER) then
	util.AddNetworkString "ttt_inspect_body"
	net.Receive("ttt_inspect_body", function(len, ply)
		local ent = net.ReadEntity()
		local confirmed = net.ReadBool()

		if (not IsValid(ent) or not ent:GetNW2Bool("IsPlayerBody", false)) then
			return
		end
		
		if (not confirmed and ent:GetPos():Distance(ply:GetShootPos()) > MAX_DISTANCE * 1.2) then
			return
		end

		if (confirmed and ent:GetPos():Distance(ply:GetPos()) > MAX_DISTANCE * 2) then
			return
		end

		hook.Run("TTTRWPlayerInspectBody", ply, ent, ent:GetPos(), ply:KeyDown(IN_WALK))
	end)

	util.AddNetworkString "ttt_call_detective"
	net.Receive("ttt_call_detective", function(len, ply)
		local ent = net.ReadEntity()

		if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE or not ply:Alive()) then
			return
		end

		if (not IsValid(ent) or not ent:GetNW2Bool("IsPlayerBody", false) or ent:GetPos():Distance(ply:GetPos()) > MAX_DISTANCE * 2) then
			return
		end

		if (not ent.HiddenState:GetIdentified()) then
			ply:Notify "You must identify the body first!"
			return
		end

		if (timer.Exists("ttt_player_call_cooldown_" .. ply:UserID())) then
			ply:Notify "You must wait 15 seconds between detective calls!"
			return
		end

		timer.Create("ttt_player_call_cooldown_" .. ply:UserID(), 15, 1, function() end)

		for _, det in ipairs(round.GetActivePlayersByRole "Detective") do
			net.Start "ttt_call_detective"
				net.WriteEntity(ent)
			net.Send(det)
		end

		for _, _ply in ipairs(player.GetAll()) do
			_ply:Notify(ply:Nick() .. " has called the detectives to the body of " .. ent.HiddenState:GetPlayer():Nick())
		end
	end)
else
	local bodies = {}
	local indicator = surface.GetTextureID("effects/select_ring")
	local call_outline = Color(0, 0, 0)

	net.Receive("ttt_call_detective", function(len)
		local ent = net.ReadEntity()

		local info = {}
		info.pos = ent:GetPos()
		info.end_time = CurTime() + 30

		bodies[ent] = info
	end)

	hook.Add("HUDPaint", "ttt_call_detective", function()
		for body, info in pairs(bodies) do
			if (not IsValid(body) or not bodies[body]) then
				continue
			end
		
			if (CurTime() > info.end_time) then
				bodies[body] = nil
				continue
			end

			local scrpos = info.pos:ToScreen()
			if (not scrpos.visible) then
				continue
			end

			surface.SetTexture(indicator)
			
			surface.SetDrawColor(ttt.roles.Detective.Color)

			local sz = IsOffScreen(scrpos) and 12 or 24
			scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
			scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
			if (IsOffScreen(scrpos)) then return end

			local text = math.ceil(info.end_time - CurTime()) .. " "
			surface.SetFont "ttt_radar_num_font"
			local w, h = surface.GetTextSize(text)

			draw.SimpleTextOutlined(text, "ttt_radar_num_font", scrpos.x, scrpos.y, white_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, call_outline)

			surface.SetDrawColor(ttt.roles.Traitor.Color)

			surface.DrawOutlinedRect(scrpos.x - w / 2 - 5, scrpos.y - h / 2 - 5, w + 10, h + 10)
			surface.DrawOutlinedRect(scrpos.x - w / 2 - 6, scrpos.y - h / 2 - 6, w + 12, h + 12)
		end
	end)

	hook.Add("ShowEndRoundScreen", "ttt_call_detective", function()
		bodies = {}
	end)
end

function GM:TryInspectBody(ply)
	local tr = ply:GetEyeTrace(MASK_SHOT)

	if (not IsValid(tr.Entity) or tr.HitPos:Distance(ply:GetShootPos()) > MAX_DISTANCE) then
		return false
	end

	if (not tr.Entity:GetNW2Bool("IsPlayerBody", false)) then
		return false
	end

	if (CLIENT) then
		net.Start "ttt_inspect_body"
			net.WriteEntity(tr.Entity)
			net.WriteBool(false)
		net.SendToServer()
	end

	hook.Run("TTTRWPlayerInspectBody", ply, tr.Entity, tr.HitPos, ply:KeyDown(IN_WALK))

	return true
end


function GM:TTTRWPlayerInspectBody(ply, ent, pos, is_silent)
	if (CLIENT) then
		if (not IsFirstTimePredicted() or IsValid(ttt.InspectMenu)) then
			return
		end

		ttt.InspectBody = ent
		ttt.InspectMenu = vgui.Create "ttt_body_inspect"
		ttt.InspectMenu:SetSize(ScrW() * 0.25, ScrH() * 0.27)
		ttt.InspectMenu:Center()
		ttt.InspectMenu:MakePopup()
		ttt.InspectMenu:SetKeyboardInputEnabled(false)
		ttt.InspectMenu.Position = pos
		ttt.InspectMenu.MaxDistance = MAX_DISTANCE
	else
		ent.HiddenState:SetVisibleTo(ply)

		local creds = ent.HiddenState:GetCredits()
		if (ply:Alive() and creds > 0 and ply:GetRoleData().DefaultCredits) then
			ply:SetCredits(ply:GetCredits() + creds)
			ply:Notify("You have received " .. creds .. " credit" .. (creds == 1 and "" or "s") .. " from the body")
			ent.HiddenState:SetCredits(0)
		end

		if (ply:Alive() and not is_silent and not ent.HiddenState:GetIdentified()) then
			ent.HiddenState:SetIdentified(true)

			for _, oply in pairs(player.GetAll()) do
				oply:Notify(ply:Nick() .. " has found " .. ent.HiddenState:GetNick() .. "'s body, they were " .. (startswithvowel(ent.HiddenState:GetRole()) and "an " or "a ") .. ent.HiddenState:GetRole())
			end

			local victim = ent.HiddenState:GetPlayer()

			if (not IsValid(victim)) then
				return
			end

			for _, oply in ipairs(victim.Killed) do
				if (IsValid(oply) and not oply:GetConfirmed()) then
					oply:SetConfirmed(true)

					for _, a in pairs(player.GetAll()) do
						a:Notify(ply:Nick() .. " has confirmed " .. oply:Nick() .. "'s death")
					end
				end
			end
		end
	end
end