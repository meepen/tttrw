
local close = Material("tttrw/close.png")



local PANEL = {}

function PANEL:PerformLayout()
	self:SetText("")
end

function PANEL:DoClick()
	local parent = self:GetParent()
	if (parent) then
		parent:Remove()
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(close)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("ttt_close_button", PANEL, "DButton")



local PANEL = {}

function PANEL:Init()
	self.Text = vgui.Create("DLabel", self)
	self.Text:SetText("You have 0 credits remaining")
	self.Text:SetTextColor(Color(37, 151, 139)) -- TODO: font
end

function PANEL:PerformLayout(w, h)
	self.Text:SetSize(w, h)
	self.Text:SetContentAlignment(5) -- Center
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, Color(41, 41, 41))
end

vgui.Register("ttt_credit_remaining", PANEL, "DPanel")



local PANEL = {}

function PANEL:Init()
end

function PANEL:PerformLayout(w, h)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, Color(41, 41, 41))
end

vgui.Register("ttt_equipment_list", PANEL, "DPanel")



local PANEL = {}

function PANEL:Init()
	self.Text = vgui.Create("ttt_credit_remaining", self)
	self.BuyList = vgui.Create("ttt_equipment_list", self)
end

function PANEL:PerformLayout(w, h)
	local space = 5
	
	-- Text
	local textHeight = h / 9
	self.Text:SetSize(w, textHeight)

	self.Text:Dock(TOP)
	self.Text:DockMargin(0, 0, 0, space)
	
	
	-- List
	local heighLeft = h - textHeight - space * 2
	self.BuyList:SetSize(w, heighLeft)

	self.BuyList:Dock(TOP)
	self.BuyList:DockMargin(0, space, 0, 0)
end

function PANEL:Paint() end

vgui.Register("ttt_credit_screen", PANEL, "DPanel")



local PANEL = {}

function PANEL:PerformLayout()
	
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, Color(41, 41, 41))
end

vgui.Register("ttt_item_screen", PANEL, "DPanel")



local PANEL = {}

function PANEL:Init()
	self.CloseButton = vgui.Create("ttt_close_button", self)
	self.CreditScreen = vgui.Create("ttt_credit_screen", self)
	self.ItemScreen = vgui.Create("ttt_item_screen", self)
end

function PANEL:PerformLayout()
	local scrw, scrh = ScrW(), ScrH()
	local w, h = scrw / 2.5, scrh / 2.1
	self:SetSize(w, h)
	self:SetPos(scrw / 2 - w / 2, scrh / 2 - h / 2)
	
	
	-- Close button
	local size = w * 0.045
	size = 2 ^ math.Round(math.log(size, 2))
	local space = size / 2
	self.CloseButton:SetSize(size, size)
	
	self.CloseButton:Dock(RIGHT)
	self.CloseButton:DockMargin(space, space, space, h - size - space)
	
	
	-- Credit screen
	local spaceLeft = w - space * 4 - size
	
	self.CreditScreen:Dock(LEFT)
	self.CreditScreen:SetSize(spaceLeft / 2, h)
	self.CreditScreen:DockMargin(space, space, space / 2, space)
	
	-- Item screen
	self.ItemScreen:Dock(LEFT)
	self.ItemScreen:SetSize(spaceLeft / 2, h)
	self.ItemScreen:DockMargin(space / 2, space, space / 2, space)
	
	
	self:MakePopup()
end

function PANEL:Paint(w, h)
	draw.RoundedBox(5, 0, 0, w, h, Color(0, 0, 0, 224))
end

vgui.Register("ttt_equipment_menu", PANEL, "DPanel")



if (ttt.equipment_menu) then
	ttt.equipment_menu:Remove()
	ttt.equipment_menu = nil
end

concommand.Add("buyshit", function()
	if (ttt.equipment_menu) then
		ttt.equipment_menu:Remove()
		ttt.equipment_menu = nil
	else
		ttt.equipment_menu = vgui.Create("ttt_equipment_menu", GetHUDPanel())
	end
end)

