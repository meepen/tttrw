local circles = include("libraries/circles.lua")

tttrw_radial_buy_menu_hover = CreateConVar("tttrw_radial_buy_menu_hover", 1, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_radial_buy_menu = CreateConVar("tttrw_radial_buy_menu", 1, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
local radius = ScrW() * 0.2
local innerSize = 0.1
local outline = 2
local iconSize = ScrW() * 0.05

local backgroundColor = Color(0, 0, 0, 150)
local outlineColor = Color(6, 21, 26)
local hightlightColor = Color(255, 255, 255)
local failureColor = Color(255, 0, 0, 20)
local textColor = Color(255, 255, 255)

surface.CreateFont("ttt_radial_buy_menu_title_font", {
	font = 'Lato',
	size = ScrH() / 44,
	weight = 200
})

surface.CreateFont("ttt_radial_buy_menu_text_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 200
})

local circleBackground = circles.New(CIRCLE_FILLED, radius, centerX, centerY)
circleBackground:SetColor(backgroundColor)
circleBackground:SetDistance(50)

local circleOutline = circles.New(CIRCLE_OUTLINED, radius, centerX, centerY, outline)
circleOutline:SetColor(outlineColor)

local circleInnerOutline = circles.New(CIRCLE_OUTLINED, radius * innerSize, centerX, centerY, outline)
circleInnerOutline:SetColor(outlineColor)
circleInnerOutline:SetDistance(5)

local circleHighlight = circles.New(CIRCLE_OUTLINED, radius, centerX, centerY, outline)
circleHighlight:SetColor(hightlightColor)

local circleInnerHighlight = circles.New(CIRCLE_OUTLINED, radius * innerSize, centerX, centerY, outline)
circleInnerHighlight:SetColor(hightlightColor)

local equipmentList = {}

local function GetSelectedEquipment()
	local x, y = input.GetCursorPos()
	x, y = centerX - x, centerY - y
	local h = math.sqrt(x^2 + y^2)

	if (h < radius * innerSize) then
		return 0
	end

	if (h > radius) then return end

	local mouseAngle = math.acos(x / h)

	if (y < 0) then
		mouseAngle = 2 * math.pi - mouseAngle
	end

	local selectedEquipment = equipmentList[math.floor(mouseAngle / (2 * math.pi) * #equipmentList) + 1]

	if selectedEquipment.Cost > LocalPlayer():GetCredits() then return end

	return selectedEquipment
end

function GM:CloseRadialBuyMenu(should_buy)
	if (not self.RadialMenuOpen) then return end
	self.RadialMenuOpen = false

	if (should_buy) then
		local selectedEquipment = GetSelectedEquipment()

		if selectedEquipment then
			if selectedEquipment == 0 then
				self:OpenBuyMenu()
			elseif istable(selectedEquipment) then
				RunConsoleCommand("ttt_buy_equipment", selectedEquipment.ClassName)
			end
		end
	end

	gui.EnableScreenClicker(false)
end

local function DrawRadialMenu()
	if (input.IsMouseDown(MOUSE_LEFT)) then
		hook.Run("CloseRadialBuyMenu", true)

		return
	end

	local deltaAngle = math.pi * 2 / #equipmentList

	draw.NoTexture()
	circleBackground()
	circleOutline()

	for i, equipment in ipairs(equipmentList) do
		if (equipment.Cost > LocalPlayer():GetCredits()) then
			draw.NoTexture()
			equipment.Circle()
		end
	end

	for i, equipment in ipairs(equipmentList) do
		local xOffset, yOffset = math.cos(equipment.Angle) * radius, math.sin(equipment.Angle) * radius
		surface.SetDrawColor(outlineColor)
		surface.DrawLine(centerX + xOffset * innerSize, centerY + yOffset * innerSize, centerX + xOffset, centerY + yOffset)

		xOffset, yOffset = math.cos(equipment.Angle - deltaAngle * 0.5) * radius * 0.4, math.sin(equipment.Angle - deltaAngle * 0.5) * radius * 0.4
		surface.SetFont("ttt_radial_buy_menu_title_font")
		local textWidth, textHeight = surface.GetTextSize(equipment.Name)
		surface.SetTextColor(textColor)
		surface.SetTextPos(centerX + xOffset - textWidth * 0.5, centerY + yOffset - textHeight * 0.5)
		surface.DrawText(equipment.Name)

		xOffset, yOffset = math.cos(equipment.Angle - deltaAngle * 0.5) * radius * 0.75, math.sin(equipment.Angle - deltaAngle * 0.5) * radius * 0.75
		surface.SetDrawColor(textColor)
		surface.SetMaterial(equipment.Material)
		surface.DrawTexturedRect(centerX + xOffset - iconSize * 0.5, centerY + yOffset - iconSize * 0.5, iconSize, iconSize)
	end

	do
		local text = "Goto regular"
		surface.SetFont("ttt_radial_buy_menu_text_font")
		local textWidth, textHeight = surface.GetTextSize(text)
		surface.SetTextColor(textColor)
		surface.SetTextPos(centerX - textWidth * 0.5, centerY - textHeight * 1)
		surface.DrawText(text)
		text = "buy menu"
		textWidth, textHeight = surface.GetTextSize(text)
		surface.SetTextPos(centerX - textWidth * 0.5, centerY)
		surface.DrawText(text)
	end

	local selectedEquipment = GetSelectedEquipment()

	draw.NoTexture()
	if (selectedEquipment == 0) then
		circleInnerOutline:SetColor(hightlightColor)
		circleInnerOutline()

		return
	else
		circleInnerOutline:SetColor(outlineColor)
		circleInnerOutline()
	end

	if (not selectedEquipment) then return end

	circleHighlight:SetAngles(math.deg(selectedEquipment.Angle - deltaAngle), math.deg(selectedEquipment.Angle))
	circleHighlight()

	circleInnerHighlight:SetAngles(math.deg(selectedEquipment.Angle - deltaAngle), math.deg(selectedEquipment.Angle))
	circleInnerHighlight()

	local xOffset, yOffset = math.cos(selectedEquipment.Angle) * radius, math.sin(selectedEquipment.Angle) * radius
	surface.SetDrawColor(hightlightColor)
	surface.DrawLine(centerX + xOffset * innerSize, centerY + yOffset * innerSize, centerX + xOffset, centerY + yOffset)
	xOffset, yOffset = math.cos(selectedEquipment.Angle - deltaAngle) * radius, math.sin(selectedEquipment.Angle - deltaAngle) * radius
	surface.DrawLine(centerX + xOffset * innerSize, centerY + yOffset * innerSize, centerX + xOffset, centerY + yOffset)
end

function GM:DrawRadialBuyMenu_DrawOverlay()
	if (self.RadialMenuOpen) then
		DrawRadialMenu()
	end
end

function GM:OpenRadialBuyMenu()
	self.RadialMenuOpen = true

	equipmentList = {}
	for classname, equipment in pairs(ttt.Equipment.List) do
		if (not LocalPlayer():CanReceiveEquipment(classname)) then
			continue
		end

		local circle = circles.New(CIRCLE_OUTLINED, radius, centerX, centerY, radius - radius * innerSize)
		circle:SetColor(failureColor)

		table.insert(equipmentList, setmetatable({Circle = circle, Material = Material(equipment.Icon)}, {__index = equipment}))
	end

	local deltaAngle = math.pi * 2 / #equipmentList

	for i, equipment in pairs(equipmentList) do
		equipment.Angle = i / #equipmentList * math.pi * 2 - math.pi
		equipment.Circle:SetAngles(math.deg(equipment.Angle - deltaAngle), math.deg(equipment.Angle))
	end

	gui.EnableScreenClicker(true)
end

function GM:TTTRWAddBuyTabs(menu)
	menu:AddTab("Radial Editor", vgui.Create "EditablePanel")
end