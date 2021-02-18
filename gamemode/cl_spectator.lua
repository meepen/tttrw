local tttrw_afk = CreateConVar("tttrw_afk", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Are you still there?")
local tttrw_afk_disable = CreateConVar("tttrw_afk_disable", 0, {FCVAR_REPLICATED}, "Disable AFK system.")

surface.CreateFont("tttrw_afk_font", {
	font = 'Lato',
	size = math.max(48, ScrH() / 20),
	weight = 400
})

local function Refresh()
	timer.Create("tttrw_afk", 80, 1, function()
		if (not LocalPlayer():Alive() or tttrw_afk_disable:GetBool()) then
			return
		end

		local seconds = 10

		timer.Create("tttrw_afk", 1, seconds + 1, function()
			if (not LocalPlayer():Alive()) then
				return
			end
			ttt.Notifications.Add("If you don't move around within " .. seconds .. " seconds, you will be slain for being AFK")
			seconds = seconds - 1

			if (seconds < 0) then
				tttrw_afk:SetBool(true)
			end
		end)
	end)
end

Refresh()

function GM:CL_PlayerSpawn(p)
	if (p == LocalPlayer()) then
		Refresh()
	end
end

function GM:DrawOverlay()
	self:DrawRadialBuyMenu_DrawOverlay()

	if (not tttrw_afk:GetBool()) then
		return
	end

	local text

	if (input.LookupBinding "gm_showhelp") then
		text = "Hit " .. input.LookupBinding "gm_showhelp" .. " and Disable Spectator Mode"
	else
		text = "Bind a key to Open Help to continue"
	end

	surface.SetFont "tttrw_afk_font"
	local w, h = surface.GetTextSize(text)
	hud.DrawTextOutlined(text, white_text, color_black, ScrW() / 2 - w / 2, 0, 3)
end

hook.Add("InputMouseApply", "tttrw_afk", function(c, x, y, a)
	if (x ~= 0 or y ~= 0) then
		Refresh()
	end
end)

hook.Add("KeyPress", "tttrw_afk", function()
	Refresh()
end)

local lastx, lasty
hook.Add("Tick", "tttrw_afk", function()
	if (not system.HasFocus()) then
		return
	end

	local x, y = gui.MousePos()
	lastx, lasty = lastx or x, lasty or y
	if (not lastx) then
		return
	end

	if (x > ScrW() or x < 0 or y > ScrH() or y < 0) then
		return
	end

	if (x ~= lastx or y ~= lasty) then
		Refresh()
	end

	lastx, lasty = x, y
end)