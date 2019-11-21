local tttrw_afk = CreateConVar("tttrw_afk", 0, {FCVAR_USERINFO, FCVAR_ARCHIVE}, "Are you still there?")

surface.CreateFont("tttrw_afk_font", {
	font = 'Lato',
	size = math.max(48, ScrH() / 20),
	weight = 400
})

local function Refresh()
	timer.Create("tttrw_afk", 80, 1, function()
		if (not LocalPlayer():Alive()) then
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
	if (not tttrw_afk:GetBool()) then
		return
	end

	local text

	if (input.LookupBinding "gm_showhelp") then
		text = "Hit " .. input.LookupBinding "gm_showhelp" .. " and Disable Spectator Mode"
	else
		text = "Type gm_showhelp in console and Disable Spectator Mode"
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