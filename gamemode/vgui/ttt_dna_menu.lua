local bg_color = CreateMaterial("ttt_dna_menu_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = Color(51, 51, 52)
surface.CreateFont("ttt_dna_menu_tab_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 200
})

surface.CreateFont("ttt_dna_menu_header_font", {
	font = 'Lato',
	size = ScrH() / 90,
	weight = 200
})

local Padding = 20

local PANEL = {}

function PANEL:Init()
    self.Inner = self:Add "ttt_dna_menu_body_inner"
    self.Inner:Dock(FILL)
    self:SetCurve(5)
    self:SetColor(ttt_body_normal)
    self:DockPadding(Padding, Padding, Padding, Padding)
    self:SetCurveTopLeft(false)
end

vgui.Register("ttt_dna_menu_body", PANEL, "ttt_curved_panel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self:SetCurve(5)
    self:SetColor(Color(41, 41, 42))

    local Padding = Padding / 2

    self:DockPadding(Padding, Padding, Padding, Padding)

    self.Header = self:Add "ttt_dna_menu_header"
    self.Header:SetText "List of DNA Samples"
    self.Header:DockPadding(0, 0, 0, Padding)
    self.Header:Dock(TOP)
    self.Header:SetZPos(0)

    self.CurrentElement = self:Add "ttt_dna_menu_current"
    self.CurrentElement:Dock(TOP)
    self.CurrentElement:SetZPos(2)

    self.ToggleButton = self:Add "ttt_curved_button"
    self.ToggleButton:SetFont "ttt_dna_menu_header_font"
    self.ToggleButton:SetText "Select DNA"
    self.ToggleButton:SetCurve(4)
    self.ToggleButton:Dock(LEFT)
    self.ToggleButton:SetColor(Color(87, 90, 90))
    self.ToggleButton:SetTextColor(Color(177, 177, 177))
    self.ToggleButton:SetZPos(3)
	self.ToggleButton:DockMargin(0, Padding, 0, 0)
	self.ToggleButton.DoClick = function()
		if (not IsValid(self.Variable)) then
			return
		end
        self.ToggleButton:SetText(LocalPlayer():GetWeapon "weapon_ttt_dna":GetCurrentDNA() == self.Variable and "Start Scan" or "Stop Scan")
		net.Start "weapon_ttt_dna"
			net.WriteEntity(self.Variable)
		net.SendToServer()
	end

    self.DeleteButton = self:Add "ttt_curved_button"
    self.DeleteButton:SetFont "ttt_dna_menu_header_font"
    self.DeleteButton:SetText "Select DNA"
    self.DeleteButton:SetCurve(4)
    self.DeleteButton:Dock(LEFT)
    self.DeleteButton:SetColor(Color(87, 90, 90))
    self.DeleteButton:SetTextColor(Color(177, 177, 177))
    self.DeleteButton:SetZPos(4)
	self.DeleteButton:DockMargin(Padding, Padding, 0, 0)
	self.DeleteButton.DoClick = function()
		if (not IsValid(self.Variable)) then
			return
		end
        self.ToggleButton:SetText("Select DNA")
        self.DeleteButton:SetText("Select DNA")
        if (IsValid(self.CurrentElement)) then
            self.CurrentElement:UnSelect()
        end
		net.Start "weapon_ttt_dna_delete"
			net.WriteEntity(self.Variable)
		net.SendToServer()
        if (not IsValid(self.Icons)) then
            return
        end
        for k, button in ipairs(self.Icons.Buttons) do
            if (button.ent == self.Variable) then
                table.remove(self.Icons.Buttons, k)
                button:Remove()
            end
        end
        self.Variable = nil
	end

    -- has to be last lol
    self.Icons = self:Add "ttt_dna_menu_icon_list"
    self.Icons:Dock(TOP)
    self.Icons:SetZPos(1)

    self:ResizeChildrenProperly()
end

function PANEL:ResizeChildrenProperly()
    local header = self.Header:GetTall()

    surface.SetFont(self.ToggleButton:GetFont())
    local _, h = surface.GetTextSize "A"
    local tall = self:GetTall() - Padding * 3.5 - h

    self.Icons:SetTall(tall / 5 * 2)
    self.CurrentElement:SetTall(tall / 5 * 2 + Padding)
    self.ToggleButton:SetTall(Padding + h)
    self.DeleteButton:SetTall(Padding + h)
end

function PANEL:PerformLayout(w, h)
    self:ResizeChildrenProperly()
end

function PANEL:Select(ent)
	self.CurrentElement:SetVariable(ent)
	self.Variable = ent
    self.ToggleButton:SetText(LocalPlayer():GetWeapon "weapon_ttt_dna":GetCurrentDNA() == self.Variable and "Stop Scan" or "Start Scan")
    self.DeleteButton:SetText("Delete DNA")
end

vgui.Register("ttt_dna_menu_body_inner", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Buttons = {}

    local Padding = Padding / 2

	self:DockMargin(0, Padding, Padding, Padding)

	local first

	for i, ent in ipairs(LocalPlayer():GetWeapon "weapon_ttt_dna":GetChildren()) do
		if (not ent.IsDNA) then
			continue
		end

		first = ent

        self.Buttons[i] = self:Add "DImageButton"
        self.Buttons[i]:SetImage(ent:GetImagePath())
        self.Buttons[i]:Dock(LEFT)
        self.Buttons[i]:SetZPos(i)
        self.Buttons[i].ent = ent
        self.Buttons[i].DoClick = function()
            self:GetParent():Select(ent)
        end
	end

	local active = LocalPlayer():GetActiveWeapon():GetCurrentDNA()
	
	local chosen = IsValid(active) and active or first

	if (IsValid(chosen)) then
		self:GetParent():Select(chosen)
	end
end

function PANEL:PerformLayout(w, h)
    for _, pnl in pairs(self:GetChildren()) do
        pnl:SetSize(h, h)
        pnl:DockMargin(Padding / 2, 0, 0, 0)
    end
end

vgui.Register("ttt_dna_menu_icon_list", PANEL, "EditablePanel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self:SetColor(ttt_body_normal)
    self:SetCurve(5)
    local Padding = Padding / 2

    self:DockPadding(Padding, Padding, Padding, Padding)
    --self:DockMargin(0, 0, 0, Padding)

    self.Icon = self:Add "DImage"
    self.Icon:Dock(LEFT)
    self.Icon:SetZPos(0)
    self.Icon:DockMargin(0, 0, Padding, 0)

    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_dna_menu_header_font"
    self.Text:Dock(FILL)
    self.Text:SetZPos(1)

    self:UnSelect()
end

function PANEL:SetVariable(ent)
    self.Icon:SetImage(ent:GetImagePath())
    self.Text:SetText(ent:GetDescription())
end

function PANEL:UnSelect()
    self.Icon:SetImage "materials/tttrw/disagree.png"
    self.Text:SetText "None selected"
end

function PANEL:PerformLayout(w, h)
    self.Icon:SetSize(h - Padding, h - Padding)
end

vgui.Register("ttt_dna_menu_current", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Tabs = {}
end

function PANEL:AddTab(text)
    local pnl = self:Add "ttt_dna_menu_tab"
    pnl:SetZPos(0x7fff - #self.Tabs)
    pnl:Dock(LEFT)
    pnl:SetText(text)

    table.insert(self.Tabs, pnl)

    return pnl
end

vgui.Register("ttt_dna_menu_tab_holder", PANEL, "EditablePanel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self:SetText "a"
    self:SetFont "ttt_dna_menu_header_font"
    self:SetCurve(3)
    self:SetColor(ttt_body_normal)
end

function PANEL:PerformLayout(w, h)
    self.Text:SizeToContents()
    self.Text:SetPos(Padding / 2, h / 2 - self.Text:GetTall() / 2)
end

function PANEL:SetFont(font)
    self.Text:SetFont(font)
end

function PANEL:SetText(t)
    self.Text:SetText(t)
    self.Text:SizeToContents()
    self.Text:SetPos(Padding / 2, self:GetTall() / 2 - self.Text:GetTall() / 2)
end

vgui.Register("ttt_dna_menu_header", PANEL, "ttt_curved_panel")


local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_dna_menu_tab_font"
    self:SetText "a"
    self:SetCurve(5)
    self:SetColor(ttt_body_normal)
    self:SetCurveBottomLeft(false)
    self:SetCurveBottomRight(false)
end

function PANEL:PerformLayout(w, h)
    self.Text:SizeToContents()
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())
end

function PANEL:SetText(t)
    self.Text:SetText(t)
    self.Text:SizeToContents()
    self:SetWide(self.Text:GetWide() + Padding * 2)
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())
end

vgui.Register("ttt_dna_menu_tab", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self:SetBody(ttt.InspectBody)
    self.Close = self:Add "ttt_close_button"
    self.Close:SetZPos(1)
    self.Close:SetColor(Color(37, 173, 125))

    self.Inner = self:Add "ttt_dna_menu_body"
    self.Inner:Dock(FILL)
    self.Tabs = self:Add "ttt_dna_menu_tab_holder"
    self.Tabs:SetHeight(Padding)
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(ScrH() * 0.02)
    self.MainTab = self.Tabs:AddTab "DNA List"
    self:DockPadding(Padding, Padding, Padding, Padding)

    self:SetColor(Color(13, 12, 13, 240))
    self:SetCurve(10)

    hook.Add("KeyPress", self, self.KeyPress)
end

local Free = {
    [IN_USE] = true,
}
function PANEL:KeyPress(ply, key)
    if (Free[key] and IsFirstTimePredicted()) then
        timer.Simple(0, function()
            if (IsValid(self)) then
                self:Remove()
            end
        end)
    end
end

function PANEL:PerformLayout(w, h)
    local _, endy = self:ScreenToLocal(self.Tabs:LocalToScreen(0, self.Tabs:GetTall()))
    local rounded2 = math.Round(endy / 2)
    self.Close:SetSize(rounded2, rounded2)
    self.Close:SetPos(w - self.Close:GetWide() - rounded2 / 2, rounded2 / 2)
end

function PANEL:SetBody(body)
    self.Body = body
end

vgui.Register("ttt_dna_menu", PANEL, "ttt_curved_panel")