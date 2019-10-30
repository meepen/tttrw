local tttrw_crosshair_color_r = CreateConVar("tttrw_crosshair_color_r", 232, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_g = CreateConVar("tttrw_crosshair_color_g", 80, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_b = CreateConVar("tttrw_crosshair_color_b", 94, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_thickness = CreateConVar("tttrw_crosshair_thickness", 2, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_length = CreateConVar("tttrw_crosshair_length", 7, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_gap = CreateConVar("tttrw_crosshair_gap", 3, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_opacity = CreateConVar("tttrw_crosshair_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_outline_opacity = CreateConVar("tttrw_crosshair_outline_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_size = CreateConVar("tttrw_crosshair_dot_size", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_opacity = CreateConVar("tttrw_crosshair_dot_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

local function drawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

	surface.DrawPoly(cir)
end

function ttt.DefaultCrosshair(x, y)
	local r = tttrw_crosshair_color_r:GetInt()
	local g = tttrw_crosshair_color_g:GetInt()
	local b = tttrw_crosshair_color_b:GetInt()
	local t = tttrw_crosshair_thickness:GetInt()
	local len = tttrw_crosshair_length:GetInt()
	local gap = tttrw_crosshair_gap:GetInt()*2
	local opacity = tttrw_crosshair_opacity:GetInt()
	local oopacity = tttrw_crosshair_outline_opacity:GetInt()
	local dot = tttrw_crosshair_dot_size:GetInt()
	local dopacity = tttrw_crosshair_dot_opacity:GetInt()

	local s = len * 2 + gap
	local startw = x - s / 2
	local starth = y - s / 2
	if (len > 0 and t > 0) then
		surface.SetDrawColor(0, 0, 0, oopacity * 255) -- outlines, counterclockwise
		surface.DrawRect(x - t / 2 - 1, starth - 1, t + 2, len + 2)
		surface.DrawRect(startw - 1 , y- t / 2 - 1, len + 2, t + 2)
		surface.DrawRect(x - t / 2 - 1, starth + s - len - 1, t + 2, len + 2)
		surface.DrawRect(startw + s - len - 1, y - t / 2 - 1, len + 2, t + 2)
		surface.SetDrawColor(r, g, b, opacity) -- crosshairs, counterclockwise
		surface.DrawRect(x - t / 2, starth, t, len)
		surface.DrawRect(startw, y - t / 2, len, t)
		surface.DrawRect(x - t / 2, starth + s - len, t, len)
		surface.DrawRect(startw + s - len, y - t / 2, len, t)
	end

	if (dot > 0) then
		surface.SetDrawColor(0, 0, 0, oopacity * 255)
		draw.NoTexture()
		drawCircle(startw + s / 2, starth + s / 2, dot + 2, 45)
		surface.SetDrawColor(r, g, b, dopacity)
		drawCircle(startw + s / 2, starth + s / 2, dot, 45)
	end
end
