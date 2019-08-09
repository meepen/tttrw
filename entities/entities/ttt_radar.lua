AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Radar"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

function ENT:Initialize()
	if (CLIENT) then
		hook.Add("HUDPaint", "TTT_Radar_HUDPaint", self.Equipment_HUDPaint)
	end
end

function ENT:OnRemove()
	if (CLIENT) then
		hook.Remove("HUDPaint", "TTT_Radar_HUDPaint")
	end
end

if (CLIENT) then

	local function IsOffScreen(scrpos)
		return not scrpos.visible or scrpos.x < 0 or scrpos.y < 0 or scrpos.x > ScrW() or scrpos.y > ScrH()
	end
	
	local function DrawTarget(tgt, size, offset, no_shrink)
		local scrpos = tgt:GetPos():ToScreen() -- sweet
		local sz = (IsOffScreen(scrpos) and (not no_shrink)) and size / 2 or size
		scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
		scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
		if IsOffScreen(scrpos) then return end
		surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

		-- Drawing full size?
		if sz == size then
			local text = math.ceil(LocalPlayer():GetPos():Distance(tgt:GetPos()))
			local w, h = surface.GetTextSize(text)
			-- Show range to target
			surface.SetTextPos(scrpos.x - w / 2, scrpos.y + (offset * sz) - h / 2)
			surface.DrawText(text)

			if tgt.t then
				-- Show time
				text = util.SimpleTime(tgt.t - CurTime(), "%02i:%02i")
				w, h = surface.GetTextSize(text)
				surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
				surface.DrawText(text)
				-- Show nickname
			elseif tgt.nick then
				text = tgt.nick
				w, h = surface.GetTextSize(text)
				surface.SetTextPos(scrpos.x - w / 2, scrpos.y + sz / 2)
				surface.DrawText(text)
			end
		end
	end
	
	local indicator = surface.GetTextureID("effects/select_ring")
	local near_cursor_dist = 180

	function ENT:Equipment_HUDPaint()
		local client = LocalPlayer()
		
		surface.SetFont("HudSelectionText")
		
		-- Player radar
		--if (not self.enable) or (not client:IsActiveSpecial()) then return end
		surface.SetTexture(indicator)
		local role, scrpos
		
		for k, tgt in pairs(player.GetAll()) do
			if (tgt == LocalPlayer()) then continue end

			scrpos = tgt:GetPos():ToScreen()
			if not scrpos.visible then continue end

			role = tgt:GetRole()
			color = color_black
			if (ttt.roles[role]) then
				color = ttt.roles[role].Color
			end
			
			surface.SetDrawColor(color.r, color.g, color.b, 255)
			surface.SetTextColor(color.r, color.g, color.b, 255)

			DrawTarget(tgt, 24, 0)
		end
	end
end
