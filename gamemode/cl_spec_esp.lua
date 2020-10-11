
local health_full = Color(58, 180, 80)
local health_ok = Color(240, 255, 0)
local health_dead = Color(255, 51, 0)

function GM:TTTRWDrawSpectatorHUD()
	for _, ply in pairs(player.GetAll()) do
		if (ply:IsDormant() or not ply:Alive() or ply:Health() <= 0) then
			continue
		end

		local scrpos = ply:GetPos():ToScreen()

		if (not scrpos.visible) then
			continue
		end

		draw.SimpleText(ply:Nick(), "TTTRWTargetID", scrpos.x, scrpos.y, white_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		surface.SetFont "TTTRWTargetID"
		local tw, th = surface.GetTextSize "A"

		local health, maxhealth = ply:Health(), ply:GetMaxHealth()

		local scrw = ScrW()
		local x, y = scrpos.x, scrpos.y

		local hppct = health / maxhealth
		local wid = math.max(40, math.min(scrw / 45, 100))
		local hpw = math.ceil(wid * hppct)
		y = y + th + 4

		local r, g, b = ColorLerp(health_dead, health_ok, health_full, hppct)
		local a = 230
		th = math.ceil(th / 2)
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(x - wid / 2, y, hpw, th)
		surface.SetDrawColor(0, 0, 0, a)
		surface.DrawRect(x - wid / 2 + hpw, y, wid - hpw, th)

		surface.SetDrawColor(12, 13, 12, 255)
		surface.DrawOutlinedRect(x - wid / 2 - 1, y - 1, wid + 2, th + 2)
	end
end
