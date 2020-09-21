local MAX_DISTANCE = 90

if (SERVER) then
	util.AddNetworkString "ttt_inspect_body"
	net.Receive("ttt_inspect_body", function(len, ply)
		local ent = net.ReadEntity()

		if (not ent:GetNW2Bool("IsPlayerBody", false)) then
			return
		end
		
		if (not IsValid(ent) or ent:GetPos():Distance(ply:GetShootPos()) > MAX_DISTANCE * 1.2) then
			return
		end

		hook.Run("TTTRWPlayerInspectBody", ply, ent, ent:GetPos(), ply:KeyDown(IN_WALK))
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
		ttt.InspectMenu:SetSize(ScrW() * 0.25, ScrH() * 0.25)
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