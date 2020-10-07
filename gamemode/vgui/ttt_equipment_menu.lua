local PANEL = {}


local function GetSpacing()
	return math.Round(ScrH() / 100)
end

local mat_evil = Material("tttrw/transparentevil.png", "noclamp smooth")
local mat_good = Material("tttrw/transparentgood.png", "noclamp smooth")

local box_background = Color(41, 41, 41, 230)
local white_text_color = Color(0xe0, 0xe0, 0xe0)

surface.CreateFont("ttt_credit_font", {
	font = "Roboto",
	size = math.max(16, ScrH() / 90),
	weight = 500
})

surface.CreateFont("ttt_equipment_header_font", {
	font = 'Lato',
	size = math.max(28, ScrH() / 47),
	weight = 200
})

surface.CreateFont("ttt_equipment_button_font", {
	font = 'Lato',
	size = math.max(28, ScrH() / 47),
	weight = 1000
})

surface.CreateFont("ttt_equipment_description_font", {
	font = 'Lato',
	size = math.max(20, ScrH() / 90),
	weight = 200
})

surface.CreateFont("ttt_equipment_status_font", {
	font = 'Lato',
	size = math.max(16, ScrH() / 90),
	weight = 200
})

local function GetHeaderSize()
	return math.max(32, math.Round(ScrH() / 30))
end

local evil_color = Color(0x93, 0x23, 0x24, 255)
local evil_icons_color = Color(255, 255, 255)
local good_icons_color = Color(255, 255, 255)
local good_color = Color(56, 80, 210, 255)

local function IsEvil()
	return not not LocalPlayer():GetRoleData().Evil
end

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(5)
	self:SetColor(box_background)
	self.Text = self:Add "DLabel"
	self.Text:SetTextColor(white_text_color)
	self.Text:SetContentAlignment(5) -- Center
	self.Text:SetFont "ttt_credit_font"

	self:OnPlayerCreditsChange(LocalPlayer(), LocalPlayer():GetCredits(), LocalPlayer():GetCredits())
	hook.Add("OnPlayerCreditsChange", self, self.OnPlayerCreditsChange)
end

function PANEL:OnPlayerCreditsChange(ply, old, new)
	if (LocalPlayer() ~= ply) then
		return
	end

	self.Text:SetText("You have " .. new .. " credit" .. (new == 1 and "" or "s"))
	self.Text:SizeToContents()
	self.Text:Center()
end

function PANEL:PerformLayout(w, h)
	self:SetTall(GetHeaderSize() / 2)
	self.Text:SizeToContents()
	self.Text:Center()
end

vgui.Register("ttt_credit_remaining", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:DoClick()
	ttt.equipment_menu:SetEquipment(self.Equipment)
end

function PANEL:DoRightClick()
	local mn = DermaMenu()
	mn:AddOption("Buy", function()
		RunConsoleCommand("ttt_buy_equipment", self.Equipment.ClassName)
	end):SetIcon("icon16/money.png")
	mn:Open()
end

vgui.Register("ttt_equipment_item_button", PANEL, "DImageButton")

local PANEL = {}

local function sum(name)
	local s = 0
	for i = 1, #name do
		s = s + name:byte(i, i) * i
	end
	return s
end

function PANEL:Init()
	self:SetColor(Color(0, 0, 0, 200))
	self:SetCurve(5)
	self.Image = self:Add "ttt_equipment_item_button"
	self.Image:Dock(FILL)
	self.Image:DockMargin(GetSpacing() / 2, GetSpacing() / 2, GetSpacing() / 2, GetSpacing() / 2)
end

function PANEL:SetEquipment(eq)
	self.Image.Equipment = eq
	math.randomseed(sum(eq.ClassName))
	local h, s, v = ColorToHSV(LocalPlayer():GetRoleData().Color)
	local n1, n2, n3 = math.random(), math.random(), math.random()
	local degree_diff = 50
	h = h + (degree_diff * n1) - degree_diff / 2
	s = s * (n2 * 0.1 + 0.9)
	v = v * (n3 * 0.1 + 0.9)

	self:SetColor(ColorAlpha(HSVToColor(h, s, v), 100))
end

function PANEL:SetImage(img)
	self.Image:SetImage(img)
end

vgui.Register("ttt_equipment_item", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self.List = self:Add "DIconLayout"
	self.List:SetSpaceX(GetSpacing() / 2)
	self.List:SetSpaceY(GetSpacing() / 2)
	self.List:Dock(FILL)
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)

	self:OnPlayerRoleChange(LocalPlayer(), LocalPlayer():GetRole(), LocalPlayer():GetRole())
end

function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply ~= LocalPlayer()) then
		return
	end

	for _, child in pairs(self.List:GetChildren()) do
		child:Remove()
	end

	local first = true

	for classname, ent in pairs(ttt.Equipment.List) do
		if (not LocalPlayer():CanReceiveEquipment(ent.ClassName)) then
			continue
		end
		local btn = self.List:Add "ttt_equipment_item"
		btn:SetImage(ent.Icon or "tttrw/disagree.png")
		btn:SetSize(57, 57)
		btn:SetEquipment(ent)
		if (first) then
			timer.Simple(0, function()
				if (not IsValid(ttt.equipment_menu)) then
					return
				end
				ttt.equipment_menu:SetEquipment(ent)
			end)
			first = false
		end
	end

	self:InvalidateLayout()
end

vgui.Register("ttt_equipment_list_scroll", PANEL, "DScrollPanel")

local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self.List = self:Add "ttt_equipment_list_scroll"
	self.List:Dock(FILL)
	self:DockPadding(GetSpacing(), GetSpacing(), GetSpacing(), GetSpacing())
end

vgui.Register("ttt_equipment_list", PANEL, "ttt_equipment_background")


local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self.BuyList = self:Add "ttt_equipment_list"
	self.BuyList:Dock(LEFT)
end

function PANEL:PerformLayout(w, h)
	self.BuyList:SetWide(w)
end

function PANEL:Paint() end

vgui.Register("ttt_credit_screen", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Init()
	self:SetCurve(2)
	self:SetColor(box_background)
end
vgui.Register("ttt_equipment_background", PANEL, "ttt_curved_panel")


local PANEL = {}
function PANEL:Init()
	self.Text = self:Add "DLabel"
	self.Text:SetTextColor(IsEvil() and evil_color or good_color)
	self.Text:SetContentAlignment(5)
	self.Text:SetFont "ttt_equipment_header_font"

	self:SetText "Default text"
	self:PerformLayout(self:GetSize())
end

function PANEL:SetText(t)
	self.Text:SetText(t)
	self.Text:SizeToContents()
	self.Text:Center()
end

function PANEL:PerformLayout(w, h)
	self:SetText(self.Text:GetText())
	self:SetTall(GetHeaderSize())
end

vgui.Register("ttt_equipment_header", PANEL, "ttt_equipment_background")


local PANEL = {}
function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self:SetText "Buy"
	self:SetContentAlignment(5)
	self:SetFont "ttt_equipment_header_font"
	self:SetColor(IsEvil() and evil_color or good_color)
	self:SetCurve(4)
end
function PANEL:DoClick()
	RunConsoleCommand("ttt_buy_equipment", self.Equipment.ClassName)
end

function PANEL:SetEquipment(eq)
	self.Equipment = eq
end

vgui.Register("ttt_equipment_buy_button", PANEL, "ttt_curved_button")


local PANEL = {}
function PANEL:Init()
	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_equipment_status_font"
	self.Text:SetTextColor(white_text_color)
	self.Image = self:Add "DImage"
	self.EnabledText = "Enabled"
	self.DisabledText = "Disabled"
	self:SetEnabled(true)
end

function PANEL:SetEnabledText(t)
	self.EnabledText = t
	self:SetEnabled(self.Enabled)
end

function PANEL:SetDisabledText(t)
	self.DisabledText = t
	self:SetEnabled(self.Enabled)
end

function PANEL:SetEnabled(b)
	self.Enabled = b
	if (b) then
		self.Text:SetText(self.EnabledText)
		self.Image:SetImage("tttrw/agree.png", "icon16/tick.png")
	else
		self.Text:SetText(self.DisabledText)
		self.Image:SetImage("tttrw/disagree.png", "icon16/cross.png")
	end
	self:PerformLayout(self:GetSize())
end

function PANEL:PerformLayout(w, h)
	self.Image:SizeToContents()
	self.Text:SizeToContents()
	local w, h = self.Text:GetSize()
	self.Image:SetSize(h / self.Image:GetTall() * self.Image:GetWide(), h)
	self.Text:Center()
	local x, y = self.Text:GetPos()
	self.Text:SetPos(x - self.Image:GetWide() / 2, y)
	self.Image:SetPos(x + self.Text:GetWide(), y)
end

vgui.Register("ttt_equipment_status", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Init()
	self.Description = self:Add "DLabel"
	self.Description:Dock(TOP)
	self.Description:SetTextColor(white_text_color)
	self.Description:SetAutoStretchVertical(true)
	self.Description:SetWrap(true)
	self.Description:SetFont "ttt_equipment_description_font"

	self.Buy = self:Add "ttt_equipment_buy_button"
	self.Buy:Dock(BOTTOM)
	self.Buy:SetZPos(0)
	self.Buy:DockMargin(0, GetSpacing() / 2, 0, 0)
	self:SetMouseInputEnabled(true)

	self.Carry = self:Add "ttt_equipment_status"
	self.Carry:Dock(BOTTOM)
	self.Carry:SetZPos(1)
	self.Carry:SetEnabledText "You can carry this."
	self.Carry:SetDisabledText "You cannot carry this."

	self.Stock = self:Add "ttt_equipment_status"
	self.Stock:Dock(BOTTOM)
	self.Stock:SetZPos(2)
	self.Stock:SetEnabledText "This item is in stock."
	self.Stock:SetDisabledText "You item is not in stock."

	self.Funds = self:Add "ttt_equipment_status"
	self.Funds:Dock(BOTTOM)
	self.Funds:SetZPos(3)
	self.Funds:SetEnabledText "You have the credits."
	self.Funds:SetDisabledText "You lack credits."

	self:DockPadding(GetSpacing() * 1.5, GetSpacing() * 1.5, GetSpacing() * 1.5, GetSpacing() * 1.5)
	self:SetTall(200)
end

function PANEL:SetEquipment(item)
	self.Description:SetText(item.Desc or "NO DESC")
	self.Description:SizeToContents()
	
	if (item.IsWeapon) then
	else
		self.Stock:SetEnabled(LocalPlayer():CanReceiveEquipment(item.ClassName))
		self.Carry:SetEnabled(LocalPlayer():CanReceiveEquipment(item.ClassName))
	end
	self.Funds:SetEnabled(LocalPlayer():GetCredits() >= (item.Cost or 1))

	self.Buy:SetEquipment(item)
end

vgui.Register("ttt_equipment_description", PANEL, "ttt_equipment_background")


local PANEL = {}

function PANEL:Init()
	self.ItemName = self:Add "ttt_equipment_header"
	self.ItemName:SetZPos(0)
	self.ItemName:Dock(TOP)
	self.ItemName:DockMargin(0, 0, 0, GetSpacing() / 2)
	self.ItemName:SetText "Example item"

	self.Credits = self:Add "ttt_credit_remaining"
	self.Credits:SetZPos(1)
	self.Credits:Dock(TOP)
	self.Credits:DockMargin(0, 0, 0, GetSpacing() / 2)

	self.ItemDesc = self:Add "ttt_equipment_description"
	self.ItemDesc:SetZPos(2)
	self.ItemDesc:Dock(FILL)
end

function PANEL:SetEquipment(item)
	self.ItemName:SetText(item.Name)
	self.ItemDesc:SetEquipment(item)
end

vgui.Register("ttt_item_screen", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.CreditScreen = self:Add "ttt_credit_screen"
	self.ItemScreen = self:Add "ttt_item_screen"

	self.CreditScreen:Dock(FILL)
	self.ItemScreen:Dock(RIGHT)
	self.ItemScreen:DockPadding(6, 0, 0, 0)

	self:Dock(TOP)
	self:SetTall(350)
end

function PANEL:PerformLayout(w, h)
	self.ItemScreen:SetWide(w / 2 - 3)
end

vgui.Register("ttt_eq_buy_screen", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)

	self.BuyTab = vgui.Create "ttt_eq_buy_screen"


	self:AddTab("Buy", self.BuyTab)
	self:SetSize(600, 440)
	self:Center()

	hook.Run("TTTRWAddBuyTabs", self)
end

function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == LocalPlayer() and old ~= new) then
		self:Remove()
	end
end

function PANEL:SetEquipment(eq)
	self.BuyTab.ItemScreen:SetEquipment(eq)
end

vgui.Register("ttt_equipment_menu", PANEL, "tttrw_base")

function GM:OpenBuyMenu()
	if (IsValid(ttt.equipment_menu)) then
		if (not ttt.equipment_menu:IsVisible()) then
			ttt.equipment_menu:Remove()
			ttt.equipment_menu:SetVisible(true)
		end
	--else
	end
	ttt.equipment_menu = vgui.Create "ttt_equipment_menu"
	ttt.equipment_menu:SetVisible(true)
	ttt.equipment_menu:MakePopup()
	ttt.equipment_menu:SetMouseInputEnabled(true)
	ttt.equipment_menu:SetKeyboardInputEnabled(false)
end

local tttrw_radial_buy_menu = CreateConVar("tttrw_radial_buy_menu", 1, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

function GM:OnContextMenuOpen()
	if (hook.Run "ShowEndRoundScreen") then
		return
	end
	if (IsValid(ttt.equipment_menu) and ttt.equipment_menu:IsVisible()) then
		ttt.equipment_menu:SetVisible(false)
		return
	end

	if (not LocalPlayer():GetRoleData().CanUseBuyMenu or ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE or not LocalPlayer():Alive()) then
		return
	end

	if (tttrw_radial_buy_menu:GetBool()) then
		self:OpenRadialBuyMenu()
	else
		self:OpenBuyMenu()
	end
end

local tttrw_radial_buy_menu_hover = CreateConVar("tttrw_radial_buy_menu_hover", 1, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

function GM:OnContextMenuClose()
	hook.Run("CloseRadialBuyMenu", tttrw_radial_buy_menu_hover:GetBool())
end