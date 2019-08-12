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

concommand.Add("tttrw_crosshair_menu", function()
	local frame = vgui.Create("DFrame")
	frame:SetPos(ScrW()/2-400,ScrH()/2-250)
	frame:SetSize(800,500)
	frame:SetTitle("Crosshair Menu")
	frame:SetVisible(true)
	frame:SetDraggable(true)
	frame:ShowCloseButton(true)
	frame:MakePopup()

	local crosshair = vgui.Create("EditablePanel", frame)
	crosshair:SetPos(25,0)
	crosshair:SetSize(400,475)
	function crosshair:Paint(w, h)
		ttt.DefaultCrosshair(w / 2, h / 2)
	end

	local col = vgui.Create("DColorMixer", frame)
	col:SetPos(450,50)
	col:SetSize(300,150)
	col:SetPalette(true)
	col:SetWangs(true)
	col:SetAlphaBar(false)
	col:SetColor(Color(GetConVar("tttrw_crosshair_color_r"):GetInt(),GetConVar("tttrw_crosshair_color_g"):GetInt(),GetConVar("tttrw_crosshair_color_b"):GetInt()))
	col:SetConVarR("tttrw_crosshair_color_r")
	col:SetConVarG("tttrw_crosshair_color_g")
	col:SetConVarB("tttrw_crosshair_color_b")

	local thick = vgui.Create("DNumSlider", frame)
	thick:SetPos(450,200)
	thick:SetSize(300,50)
	thick:SetText("Thickness")
	thick:SetMin(0)
	thick:SetMax(30)
	thick:SetDecimals(0)
	thick:SetConVar("tttrw_crosshair_thickness")

	local len = vgui.Create("DNumSlider", frame)
	len:SetPos(450,240)
	len:SetSize(300,50)
	len:SetText("Length")
	len:SetMin(0)
	len:SetMax(100)
	len:SetDecimals(0)
	len:SetConVar("tttrw_crosshair_length")

	local gap = vgui.Create("DNumSlider", frame)
	gap:SetPos(450,280)
	gap:SetSize(300,50)
	gap:SetText("Gap")
	gap:SetMin(0)
	gap:SetMax(50)
	gap:SetDecimals(0)
	gap:SetConVar("tttrw_crosshair_gap")

	local op = vgui.Create("DNumSlider", frame)
	op:SetPos(450,320)
	op:SetSize(300,50)
	op:SetText("Opacity")
	op:SetMin(0)
	op:SetMax(255)
	op:SetDecimals(0)
	op:SetConVar("tttrw_crosshair_opacity")

	local outop = vgui.Create("DNumSlider", frame)
	outop:SetPos(450,360)
	outop:SetSize(300,50)
	outop:SetText("Outline Opacity")
	outop:SetMin(0)
	outop:SetMax(255)
	outop:SetDecimals(0)
	outop:SetConVar("tttrw_crosshair_outline_opacity")

	local dot = vgui.Create("DNumSlider", frame)
	dot:SetPos(450,400)
	dot:SetSize(300,50)
	dot:SetText("Dot Size")
	dot:SetMin(0)
	dot:SetMax(20)
	dot:SetDecimals(0)
	dot:SetConVar("tttrw_crosshair_dot_size")

	local dotop = vgui.Create("DNumSlider", frame)
	dotop:SetPos(450,440)
	dotop:SetSize(300,50)
	dotop:SetText("Dot Opacity")
	dotop:SetMin(0)
	dotop:SetMax(255)
	dotop:SetDecimals(0)
	dotop:SetConVar("tttrw_crosshair_dot_opacity")

	local reset = vgui.Create("DButton", frame)
	reset:SetPos(175,425)
	reset:SetSize(100,50)
	reset:SetText("Reset")
	function reset:DoClick()
		col:SetColor(Color(232,80,94))
		thick:SetValue(2)
		len:SetValue(7)
		gap:SetValue(3)
		op:SetValue(255)
		outop:SetValue(255)
		dot:SetValue(0)
		dotop:SetValue(255)
	end
end)

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
