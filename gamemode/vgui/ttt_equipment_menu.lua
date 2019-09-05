local PANEL = {}


local function GetSpacing()
	return math.Round(ScrH() / 100)
end

local function GetHeaderSize()
	return math.Round(ScrH() / 30)
end

local box_background = Color(41, 41, 41, 230)
local white_text_color = Color(0xe0, 0xe0, 0xe0)

surface.CreateFont("ttt_credit_font", {
	font = 'Lato',
	size = ScrH() / 70,
	weight = 200
})

surface.CreateFont("ttt_equipment_header_font", {
	font = 'Lato',
	size = ScrH() / 47,
	weight = 200
})

surface.CreateFont("ttt_equipment_button_font", {
	font = 'Lato',
	size = ScrH() / 47,
	weight = 1000
})

surface.CreateFont("ttt_equipment_description_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 200
})

surface.CreateFont("ttt_equipment_status_font", {
	font = 'Lato',
	size = ScrH() / 90,
	weight = 200
})

local evil_color = Color(0x93, 0x23, 0x24, 255)
local evil_icons_color = Color(255, 255, 255)
local good_color = Color(0, 0, 255, 255)

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(5)
	self:SetColor(box_background)
	self.Text = self:Add "DLabel"
	self.Text:SetTextColor(evil_color) -- TODO: font
	self.Text:SetContentAlignment(5) -- Center
	self.Text:SetFont "ttt_credit_font"
	self.Text:SetText "You have 0 credits remaining"
end

function PANEL:PerformLayout(w, h)
	self:SetTall(GetHeaderSize())
	self.Text:SizeToContents()
	self.Text:Center()
	BaseClass.PerformLayout(self, self:GetSize())
end

vgui.Register("ttt_credit_remaining", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:DoClick()
	ttt.equipment_menu:SetEquipment(self.Equipment)
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

	print(h, s, v)
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
		btn:SetSize(66, 66)
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

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_equipment_list", PANEL, "EditablePanel")


local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self.Text = self:Add "ttt_credit_remaining"
	self.Text:Dock(TOP)
	self.Text:DockMargin(0, 0, 0, GetSpacing())

	self.BuyList = self:Add "ttt_equipment_list"
	self.BuyList:Dock(LEFT)
end

function PANEL:PerformLayout(w, h)
	self.BuyList:SetWide(w)
end

function PANEL:Paint() end

vgui.Register("ttt_credit_screen", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_equipment_background", PANEL, "EditablePanel")


local PANEL = {}
function PANEL:Init()
	self.Text = self:Add "DLabel"
	self.Text:SetTextColor(evil_color)
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


local buy_button_mat = CreateMaterial("ttt_buy_material", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = string.format("{ %i %i %i }", evil_color.r, evil_color.g, evil_color.b),
	["$alpha"] = 1
})
local PANEL = {}
function PANEL:Init()
	self.Button = self:Add "DButton"
	self.Button:SetFont "ttt_equipment_button_font"
	self.Button:SetText "Buy"
	self.Button:SetTextColor(box_background)
	self.Button.Paint = self.PaintButton
	self.Button.PerformLayout = function(self, w, h)
		self:SetTall(self:GetParent():GetTall())
	end

	function self.Button:DoClick()
		RunConsoleCommand("ttt_buy_equipment", self.Equipment.ClassName)
	end

	self:SetMouseInputEnabled(true)

	self:PerformLayout(self:GetSize())
end

function PANEL:PerformLayout(w, h)
	self.Button:SizeToContentsY(GetSpacing())
	self.Button:SetWide(w * 2 / 3)
	self.Button:Center()
	self:SetTall(self.Button:GetTall())

	if (self.Button.Mesh) then
		self.Button.Mesh:Destroy()
		self.Button.Mesh = nil
	end

	local w = w * 2 / 3

	self.Button.Mesh = hud.BuildCurvedMesh(5, 0, 0, w, h)
end

function PANEL:PaintButton(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(buy_button_mat)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

function PANEL:Paint() end

function PANEL:SetEquipment(eq)
	self.Button.Equipment = eq
end

vgui.Register("ttt_equipment_buy_button", PANEL, "EditablePanel")


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
	self.Carry:SetEnabledText "You can carry this equipment"
	self.Carry:SetDisabledText "You cannot carry this equipment"

	self.Stock = self:Add "ttt_equipment_status"
	self.Stock:Dock(BOTTOM)
	self.Stock:SetZPos(2)
	self.Stock:SetEnabledText "This item is in stock."
	self.Stock:SetDisabledText "You item is not in stock."

	self:DockPadding(GetSpacing() * 1.5, GetSpacing() * 1.5, GetSpacing() * 1.5, GetSpacing() * 1.5)
end

function PANEL:SetEquipment(item)
	self.Description:SetText(item.Desc or "NO DESC")
	self.Description:SizeToContents()
	
	if (item.IsWeapon) then
	else
		self.Stock:SetEnabled(LocalPlayer():CanReceiveEquipment(item.ClassName))
		self.Carry:SetEnabled(LocalPlayer():CanReceiveEquipment(item.ClassName))
	end
	self.Buy:SetEquipment(item)
end

vgui.Register("ttt_equipment_description", PANEL, "ttt_equipment_background")


local PANEL = {}

function PANEL:Init()
	self.ItemName = self:Add "ttt_equipment_header"
	self.ItemName:SetZPos(0)
	self.ItemName:Dock(TOP)
	self.ItemName:DockMargin(0, 0, 0, GetSpacing())
	self.ItemName:SetText "Example item"

	self.ItemDesc = self:Add "ttt_equipment_description"
	self.ItemDesc:SetZPos(1)
	self.ItemDesc:Dock(TOP)
	self.ItemDesc:DockMargin(0, 0, 0, GetSpacing())

	self.BoughtText = self:Add "ttt_equipment_header"
	self.BoughtText:SetZPos(2)
	self.BoughtText:Dock(TOP)
	self.BoughtText:DockMargin(0, 0, 0, GetSpacing())
	self.BoughtText:SetText "Bought items"

	self.BoughtItems = self:Add "ttt_equipment_background"
	self.BoughtItems:SetZPos(3)
	self.BoughtItems:Dock(TOP)
end

function PANEL:SetEquipment(item)
	self.ItemName:SetText(item.Name)
	self.ItemDesc:SetEquipment(item)
end

function PANEL:PerformLayout()
	self.ItemName:SetTall(GetHeaderSize())
	self.ItemDesc:SetTall((self:GetTall() - GetSpacing() * 2 - GetHeaderSize() * 2) * 4/7)
	self.BoughtText:SetTall(GetHeaderSize())
	self.BoughtItems:SetTall((self:GetTall() - GetSpacing() * 2 - GetHeaderSize() * 2) * 3/7)
end

function PANEL:Paint(w, h)
	--draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_item_screen", PANEL, "EditablePanel")


local PANEL = {}

local mat = Material("tttrw/transparentevil.png", "noclamp smooth")

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self.CloseButton = self:Add "ttt_close_button"
	self.CreditScreen = self:Add "ttt_credit_screen"
	self.ItemScreen = self:Add "ttt_item_screen"

	self.CloseButton:SetColor(evil_color)

	self.CloseButton:SetZPos(1)
	self.CloseButton:Dock(TOP)
	self.CreditScreen:Dock(LEFT)
	self.ItemScreen:Dock(LEFT)

	self:OnScreenSizeChanged(ScrW(), ScrH())
	timer.Simple(0, function()
		mat:SetFloat("$alpha", 0.03)
		mat:SetVector("$color", evil_icons_color:ToVector())
	end)
end

function PANEL:OnScreenSizeChanged(w, h)
	w = w * 0.4
	h = h * 0.5
	self:DockPadding(GetSpacing(), GetSpacing(), GetSpacing(), GetSpacing())
	self.CloseButton:SetSize(GetHeaderSize(), GetHeaderSize())

	local spaceLeft = w - GetSpacing() * 4 - GetHeaderSize()
	self.CreditScreen:SetWide(spaceLeft * 3 / 7)
	self.ItemScreen:SetWide(spaceLeft * 4 / 7)

	self.CreditScreen:DockMargin(0, 0, GetSpacing(), 0)
	self.ItemScreen:DockMargin(0, 0, GetSpacing(), 0)

	self:SetSize(w, h)
	self:Center()
end

function PANEL:SetEquipment(eq)
	self.ItemScreen:SetEquipment(eq)
end

function PANEL:PerformLayout(w, h)
	self.Mesh = hud.BuildCurvedMesh(6, 0, 0, self:GetWide(), self:GetTall())
end

local bg_color = CreateMaterial("ttt_color_material", "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local matrix = Matrix()
function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(bg_color)
		render.DrawScreenQuad()

		render.SetMaterial(mat)
		local pw, ph = mat:GetInt "$realwidth", mat:GetInt "$realheight"
		if (pw) then
			for x = 0, w, pw do
				for y = 0, h, ph do
					render.DrawQuad(Vector(x, y), Vector(x + pw, y), Vector(x + pw, y + ph), Vector(x, y + ph))
				end
			end
		end
	hud.EndStenciledMesh()
end
vgui.Register("ttt_equipment_menu", PANEL, "EditablePanel")

if (IsValid(ttt.equipment_menu)) then
	ttt.equipment_menu:Remove()
	ttt.equipment_menu = nil
end

function GM:OnContextMenuOpen()
	if (not LocalPlayer():GetRoleData().CanUseBuyMenu or ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE or not LocalPlayer():Alive()) then
		return
	end

	if (IsValid(ttt.equipment_menu)) then
		if (not ttt.equipment_menu:IsVisible()) then
			ttt.equipment_menu:SetVisible(true)
		end
	else
		ttt.equipment_menu = GetHUDPanel():Add "ttt_equipment_menu"
		ttt.equipment_menu:SetVisible(true)
	end
	ttt.equipment_menu:MakePopup()
	ttt.equipment_menu:SetMouseInputEnabled(true)
	ttt.equipment_menu:SetKeyboardInputEnabled(false)
end

function GM:OnContextMenuClose()
	if (IsValid(ttt.equipment_menu)) then
		ttt.equipment_menu:SetVisible(false)
	end
end