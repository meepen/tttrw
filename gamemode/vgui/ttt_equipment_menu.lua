local PANEL = {}

local Spacing = ScrH() / 90

local HeaderSize = ScrH() / 30

local box_background = Color(41, 41, 41, 252)

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

local evil_color = Color(255, 0, 0, 255)
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
	self.Text = vgui.Create("ttt_credit_remaining", self)
	self.BuyList = vgui.Create("ttt_equipment_list", self)
	self.BuyList:Dock(LEFT)
	self.Text:Dock(TOP)
end

function PANEL:PerformLayout(w, h)
	self.BuyList:DockMargin(0, Spacing, 0, 0)
end

function PANEL:Paint() end

vgui.Register("ttt_credit_screen", PANEL, "DPanel")


local PANEL = {}

function PANEL:PerformLayout()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, box_background)
end

vgui.Register("ttt_item_screen", PANEL, "DPanel")


local PANEL = {}

local mat = Material("tttrw/evil.png", "noclamp smooth")

function PANEL:Init()
	self.CloseButton = vgui.Create("ttt_close_button", self)
	self.CloseButton:SetColor(evil_color)
	self.CreditScreen = vgui.Create("ttt_credit_screen", self)
	self.ItemScreen = vgui.Create("ttt_item_screen", self)
end

function PANEL:PerformLayout()
	local scrw, scrh = ScrW(), ScrH()
	local w, h = scrw / 2.5, scrh / 2.1
	self:SetSize(w, h)
	self:SetPos(scrw / 2 - w / 2, scrh / 2 - h / 2)

	local size = w * 0.045
	size = 2 ^ math.Round(math.log(size, 2))
	self.CloseButton:SetSize(size, size)

	self.CloseButton:Dock(RIGHT)
	self.CloseButton:DockMargin(Spacing, Spacing, Spacing, h - size - Spacing)


	-- Credit screen
	local spaceLeft = w - Spacing * 4 - size
	
	self.CreditScreen:Dock(LEFT)
	self.CreditScreen:SetWide(spaceLeft / 2)
	self.CreditScreen:DockMargin(Spacing, Spacing, Spacing / 2, Spacing)
	
	-- Item screen
	self.ItemScreen:Dock(LEFT)
	self.ItemScreen:SetWide(spaceLeft / 2)
	self.ItemScreen:DockMargin(Spacing / 2, Spacing, Spacing / 2, Spacing)
	
	mat:SetFloat("$alpha", 0.6)
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
colour:SetFloat("$alpha", 0.1)

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

