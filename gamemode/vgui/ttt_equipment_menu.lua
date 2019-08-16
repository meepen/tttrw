local PANEL = {}

local Spacing = math.Round(ScrH() / 100)

local HeaderSize = ScrH() / 30

local box_background = Color(41, 41, 41, 240)
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

local evil_color = Color(0x93, 0x23, 0x24, 255)
local evil_icons_color = Color(255, 255, 255)
local good_color = Color(0, 0, 255, 255)

function PANEL:Init()
	self.Text = vgui.Create("DLabel", self)
	self.Text:SetTextColor(evil_color) -- TODO: font
	self.Text:SetContentAlignment(5) -- Center
	self.Text:SetFont "ttt_credit_font"
	self.Text:SetText("You have 0 credits remaining")
	self:PerformLayout(self:GetSize())
end

function PANEL:PerformLayout(w, h)
	self.Text:SizeToContents()
	self:SetTall(HeaderSize)
	self.Text:Center()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_credit_remaining", PANEL, "DPanel")


local PANEL = {}

function PANEL:Init()
	-- TODO(meep): add this lol
end

function PANEL:PerformLayout(w, h)
	self:SetWide(self:GetParent():GetWide())
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_equipment_list", PANEL, "DPanel")


local PANEL = {}

function PANEL:Init()
	self.Text = self:Add "ttt_credit_remaining"
	self.Text:Dock(TOP)
	self.Text:DockMargin(0, 0, 0, Spacing)

	self.BuyList = self:Add "ttt_equipment_list"
	self.BuyList:Dock(LEFT)
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint()
end

vgui.Register("ttt_credit_screen", PANEL, "DPanel")

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
	self:SetTall(HeaderSize)
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
	self:SetMouseInputEnabled(true)

	self:PerformLayout(self:GetSize())
end

function PANEL:PerformLayout(w, h)
	self.Button:SizeToContentsY(Spacing)
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

vgui.Register("ttt_equipment_buy_button", PANEL, "EditablePanel")


local PANEL = {}
function PANEL:Init()
	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_equipment_description_font"
	self.Text:SetTextColor(white_text_color)
	self.Image = self:Add "DImage"
	self:SetEnabled(true)
end

function PANEL:SetEnabled(b)
	if (b) then
		self.Text:SetText "This item is in stock."
		self.Image:SetImage("tttrw/agree.png", "icon16/tick.png")
	else
		self.Text:SetText "This item is not in stock."
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

vgui.Register("ttt_equipment_available", PANEL, "EditablePanel")

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
	self.Buy:DockMargin(0, Spacing / 2, 0, 0)
	self:SetMouseInputEnabled(true)

	self.Available = self:Add "ttt_equipment_available"
	self.Available:Dock(BOTTOM)
	self.Available:SetZPos(1)

	self:DockPadding(Spacing * 1.5, Spacing * 1.5, Spacing * 1.5, Spacing * 1.5)
end

function PANEL:SetItem(item)
	self.Description:SetText(item.Description)
	self.Description:SizeToContents()
end

function PANEL:PerformLayout(w, h)
end

vgui.Register("ttt_equipment_description", PANEL, "ttt_equipment_background")


local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled(true)
	self.ItemName = self:Add "ttt_equipment_header"
	self.ItemName:SetZPos(0)
	self.ItemName:Dock(TOP)
	self.ItemName:DockMargin(0, 0, 0, Spacing)
	self.ItemName:SetText "Example item"

	self.ItemDesc = self:Add "ttt_equipment_description"
	self.ItemDesc:SetZPos(1)
	self.ItemDesc:Dock(TOP)
	self.ItemDesc:DockMargin(0, 0, 0, Spacing)

	self.ItemDesc:SetItem {
		Description = ("Very long string to meme with "):rep(10)
	}

	self.BoughtText = self:Add "ttt_equipment_header"
	self.BoughtText:SetZPos(2)
	self.BoughtText:Dock(TOP)
	self.BoughtText:DockMargin(0, 0, 0, Spacing)
	self.BoughtText:SetText "Bought items"

	self.BoughtItems = self:Add "ttt_equipment_background"
	self.BoughtItems:SetZPos(3)
	self.BoughtItems:Dock(TOP)
end

function PANEL:PerformLayout()
	self.ItemName:SetTall(HeaderSize)
	self.ItemDesc:SetTall((self:GetTall() - Spacing * 2 - HeaderSize * 2) * 4/7)
	self.BoughtText:SetTall(HeaderSize)
	self.BoughtItems:SetTall((self:GetTall() - Spacing * 2 - HeaderSize * 2) * 3/7)
end

function PANEL:Paint(w, h)
	--draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_item_screen", PANEL, "EditablePanel")


local PANEL = {}

local mat = Material("tttrw/transparentevil.png", "noclamp smooth")

function PANEL:Init()
	self.CloseButton = vgui.Create("ttt_close_button", self)
	self.CloseButton:SetColor(evil_color)
	self.CreditScreen = vgui.Create("ttt_credit_screen", self)
	self.ItemScreen = vgui.Create("ttt_item_screen", self)
end

function PANEL:PerformLayout()
	local scrw, scrh = ScrW(), ScrH()
	local w, h = scrw / 2.5, scrh / 2.1

	local size = math.Round(HeaderSize)

	self.CloseButton:Dock(TOP)
	self.CloseButton:DockMargin(0, 0, 0, 0)
	self.CloseButton:SetSize(size, size)
	self.CloseButton:SetZPos(1)


	-- Credit screen
	local spaceLeft = w - Spacing * 4 - size

	self:DockPadding(Spacing, Spacing, Spacing, Spacing)
	
	self.CreditScreen:Dock(LEFT)
	self.CreditScreen:SetWide(spaceLeft * 3 / 7)
	self.CreditScreen:DockMargin(0, 0, Spacing, 0)
	
	-- Item screen
	self.ItemScreen:Dock(LEFT)
	self.ItemScreen:SetWide(spaceLeft * 4 / 7)
	self.ItemScreen:DockMargin(0, 0, Spacing, 0)

	self:SetSize(spaceLeft + Spacing * 4 + HeaderSize, h)
	self:Center()
	
	mat:SetFloat("$alpha", 0.03)
	mat:SetVector("$color", evil_icons_color:ToVector())

	self.Mesh = hud.BuildCurvedMesh(6, 0, 0, self:GetWide(), self:GetTall())
	
	self:MakePopup()
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
vgui.Register("ttt_equipment_menu", PANEL, "DPanel")


if (ttt.equipment_menu) then
	ttt.equipment_menu:Remove()
	ttt.equipment_menu = nil
end
ttt.equipment_menu = vgui.Create("ttt_equipment_menu", GetHUDPanel())

