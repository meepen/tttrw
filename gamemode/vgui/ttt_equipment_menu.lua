local PANEL = {}

local Spacing = math.Round(ScrH() / 100)

local HeaderSize = ScrH() / 30

local box_background = Color(41, 41, 41, 240)

surface.CreateFont("ttt_credit_font", {
	font = 'Lato',
	size = ScrH() / 70,
	weight = 200
})

surface.CreateFont("ttt_equipment_header_font", {
	font = 'Lato',
	size = ScrH() / 60,
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
function PANEL:Init()
end
function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_equipment_background", PANEL, "EditablePanel")


local PANEL = {}

function PANEL:Init()
	self.ItemName = self:Add "ttt_equipment_background"
	self.ItemName:SetZPos(0)
	self.ItemName:Dock(TOP)
	self.ItemName:DockMargin(0, 0, 0, Spacing)

	self.ItemDesc = self:Add "ttt_equipment_background"
	self.ItemDesc:SetZPos(1)
	self.ItemDesc:Dock(TOP)
	self.ItemDesc:DockMargin(0, 0, 0, Spacing)

	self.BoughtText = self:Add "ttt_equipment_background"
	self.BoughtText:SetZPos(2)
	self.BoughtText:Dock(TOP)
	self.BoughtText:DockMargin(0, 0, 0, Spacing)

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

local mat = Material("tttrw/transparent_evil.png", "noclamp smooth")

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
	local curve = 6
	local function addpos(x, y)
		mesh.Position(Vector(x, y))
		mesh.AdvanceVertex()
	end
	local function addbox(x, y, w, h)
		addpos(x, y)
		addpos(x + w, y)
		addpos(x + w, y + h)

		addpos(x, y)
		addpos(x + w, y + h)
		addpos(x, y + h)
	end

	self.Mesh = Mesh()
	mesh.Begin(self.Mesh, MATERIAL_TRIANGLES, 6 + curve * 4)
		addbox(curve, 0, self:GetWide() - curve * 2, self:GetTall())
		addbox(0, curve, curve, self:GetTall() - curve * 2)
		addbox(self:GetWide() - curve, curve, curve, self:GetTall() - curve * 2)
		local lastsin, lastcos

		for i = 0, curve do
			local rad = math.rad(i / curve * 90)
			local sin, cos = math.sin(rad), math.cos(rad)

			if (lastsin) then
				addpos(curve - sin * curve, curve - cos * curve)
				addpos(curve - lastsin * curve, curve - lastcos * curve)
				addpos(curve, curve)

				addpos(self:GetWide() - curve + lastsin * curve, curve - lastcos * curve)
				addpos(self:GetWide() - curve + sin * curve, curve - cos * curve)
				addpos(self:GetWide() - curve, curve)

				addpos(curve - lastsin * curve, self:GetTall() - curve + lastcos * curve)
				addpos(curve - sin * curve, self:GetTall() - curve + cos * curve)
				addpos(curve, self:GetTall() - curve)

				addpos(self:GetWide() - curve + sin * curve, self:GetTall() - curve + cos * curve)
				addpos(self:GetWide() - curve + lastsin * curve, self:GetTall() - curve + lastcos * curve)
				addpos(self:GetWide() - curve, self:GetTall() - curve)
			end

			lastsin, lastcos = sin, cos
		end
	mesh.End()
	
	self:MakePopup()
end
local colour = Material "pp/colour"

local bg_color = CreateMaterial("ttt_color_material"..math.random(0, 0xffff), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local matrix = Matrix()
function PANEL:Paint(w, h)
	matrix:SetTranslation(Vector(self:LocalToScreen(0, 0)))

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)
	render.SetStencilReferenceValue(1)
	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	render.SetStencilPassOperation(STENCIL_REPLACE)
	render.SetStencilFailOperation(STENCIL_KEEP)
	render.SetStencilZFailOperation(STENCIL_KEEP)
	render.ClearStencil()

	render.SetStencilEnable(true)
	render.SetMaterial(colour)
		cam.PushModelMatrix(matrix)
			render.OverrideColorWriteEnable(true, false)
				self.Mesh:Draw()
			render.OverrideColorWriteEnable(false, false)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_EQUAL)

			render.SetMaterial(bg_color)
			render.DrawScreenQuad()

			render.SetMaterial(mat)
			local pw, ph = mat:GetInt "$realwidth", mat:GetInt "$realheight"
			for x = 0, w, pw do
				for y = 0, h, ph do
					render.DrawQuad(Vector(x, y), Vector(x + pw, y), Vector(x + pw, y + ph), Vector(x, y + ph))
				end
			end
		cam.PopModelMatrix()
	render.SetStencilEnable(false)
end
vgui.Register("ttt_equipment_menu", PANEL, "DPanel")


if (ttt.equipment_menu) then
	ttt.equipment_menu:Remove()
	ttt.equipment_menu = nil
end
ttt.equipment_menu = vgui.Create("ttt_equipment_menu", GetHUDPanel())
