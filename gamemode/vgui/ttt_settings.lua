
local self = {}
local Setting_mt = {
	__index = self,
	__call = function(self, v)
		for k,v in pairs(v) do
			self[k] = v
		end
	end
}

local function AccessorFunc(self, name, fnname)
	fnname = fnname or name
	self["Get" .. fnname] = function(self)
		return self[name]
	end

	self["Set" .. fnname] = function(self, v)
		self[name] = v
		return self
	end
end

AccessorFunc(self, "ConVar")

local function Setting(name)
	local t = Settings[name] or setmetatable({
		Name = name
	}, Settings_mt)

	return t
end

local bg_color = CreateMaterial("ttt_settings_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = Color(51, 51, 52)

surface.CreateFont("ttt_settings_tab_font", {
	font = 'Lato',
	size = ScrH() / 70,
	weight = 400
})

surface.CreateFont("ttt_settings_settings_text_font", {
	font = 'Roboto',
	size = ScrH() / 80,
	weight = 0
})

surface.CreateFont("ttt_settings_header_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 200
})

local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
	self.Button.OnChange = function(_, val)
		self:OnChange(val)
	end

	self.Button:Dock(LEFT)
	self.Button:DockMargin(0, 0, Padding, 0)

	self.Label:SetMouseInputEnabled(true)
	self.Label.DoClick = function()
		self:Toggle()
	end
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(4)
end

function PANEL:PerformLayout(w, h)
	self.Button:SetWide(h)
end

vgui.Register("ttt_checkbox_label", PANEL, "DCheckBoxLabel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(6)
	self:SetColor(Color(78, 76, 80))
	self.Label = self:Add "DLabel"
	self.Label:SetFont "ttt_settings_tab_font"
	surface.SetFont(self.Label:GetFont())
	local _, h = surface.GetTextSize "A"

	self:SetTall(h + Padding)

	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
end

function PANEL:SetText(t)
	self.Label:SetText(t)
end

vgui.Register("ttt_settings_header_stuff", PANEL, "ttt_curved_panel")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self:SetCurve(6)
    self:SetColor(ttt_body_normal)
    self:DockPadding(Padding, Padding, Padding, Padding)
	self:SetCurveTopLeft(false)

	self.Left = self:Add "EditablePanel"
	self.Right = self:Add "EditablePanel"
	self.Left:Dock(LEFT)
	self.Right:Dock(FILL)

	self.Header = self.Left:Add "ttt_settings_header_stuff"
	self.Header:DockMargin(0, Padding * 2, 0, 0)
	self.Header:SetText "Gameplay Settings"
	self.Header:Dock(TOP)
	self.Header:SetZPos(0)

	self.Index = 1

	self:AddCheckBox("Aim Down Sights Toggle", "tttrw_toggle_ads")
	self:AddCheckBox("Outline players roles", "tttrw_outline_roles")
	self:AddCheckBox("Automatically Bunny hop", "ttt_bhop_cl")
	self:AddCheckBox("Lowered Ironsights", "ttt_ironsights_lowered")
end

function PANEL:AddCheckBox(desc, convar)
	self.TestLabel = self.Left:Add "ttt_checkbox_label"
	self.TestLabel:SetZPos(self.Index)
	self.Index = self.Index + 1
	self.TestLabel:DockMargin(0, Padding, 0, 0)

	self.TestLabel:SetConVar(convar)
	self.TestLabel:SetText(desc)
	self.TestLabel:SetFont "ttt_settings_settings_text_font"
	self.TestLabel:SetValue(GetConVar(convar):GetBool())
	self.TestLabel:Dock(TOP)
	surface.SetFont(self.TestLabel.Label:GetFont())
	local _, h = surface.GetTextSize "A"
	self.TestLabel:SetTall(h + Padding / 2)
end

function PANEL:PerformLayout(w, h)
	self.TestLabel:SizeToContents()
	self.TestLabel:Center()
	self.Left:SetWide(w / 2)
	BaseClass.PerformLayout(self, w, h)
end

vgui.Register("ttt_settings_body", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Tabs = {}
end

function PANEL:AddTab(text, class)
    local pnl = self:Add(class)
    pnl:SetZPos(0x7fff - #self.Tabs)
    pnl:Dock(LEFT)
    pnl:SetText(text)

    table.insert(self.Tabs, pnl)

    return pnl
end

vgui.Register("ttt_settings_tab_holder", PANEL, "EditablePanel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self:SetFont "ttt_settings_header_font"
    self:SetCurve(3)
    self:SetColor(ttt_body_normal)
end

function PANEL:PerformLayout(w, h)
    self.Text:SizeToContents()
    self.Text:SetPos(Padding / 2, h / 2 - self.Text:GetTall() / 2)

    BaseClass.PerformLayout(self, w, h)
end

function PANEL:SetFont(font)
    self.Text:SetFont(font)
end

function PANEL:SetText(t)
    self.Text:SetText(t)
    self.Text:SizeToContents()
    self.Text:SetPos(Padding / 2, self:GetTall() / 2 - self.Text:GetTall() / 2)
end

vgui.Register("ttt_settings_header", PANEL, "ttt_curved_panel")


local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_settings_tab_font"
    self:SetCurve(5)
    self:SetColor(ttt_body_normal)
    self:SetCurveBottomLeft(false)
    self:SetCurveBottomRight(false)
end

function PANEL:PerformLayout(w, h)
    self.Text:SizeToContents()
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())

    BaseClass.PerformLayout(self, w, h)
end

function PANEL:SetText(t)
    self.Text:SetText(t)
    self.Text:SizeToContents()
    self:SetWide(self.Text:GetWide() + Padding * 2)
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())
end

vgui.Register("ttt_settings_tab", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Close = self:Add "ttt_close_button"
    self.Close:SetZPos(1)
    self.Close:SetColor(Color(37, 173, 125))

    self.Inner = self:Add "ttt_settings_body"
    self.Inner:Dock(FILL)
    self.Tabs = self:Add "ttt_settings_tab_holder"
    self.Tabs:SetHeight(Padding)
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(ScrH() * 0.02)
    self.MainTab = self.Tabs:AddTab("Main Settings", "ttt_settings_tab")
    self:DockPadding(Padding * 5 / 6, Padding, Padding * 5 / 6, Padding * 5 / 6)

    self:SetColor(Color(13, 12, 13, 240))
	self:SetCurve(10)
	self:SetSize(ScrW() / 2, ScrH() / 2)
	self:Center()
	self:SetSkin "tttrw"
end

function PANEL:PerformLayout(w, h)
    local _, endy = self:ScreenToLocal(self.Tabs:LocalToScreen(0, self.Tabs:GetTall()))
    local rounded2 = math.Round(endy / 2)
    self.Close:SetSize(rounded2, rounded2)
    self.Close:SetPos(w - self.Close:GetWide() - Padding * 5 / 6, rounded2 / 2)
    
    BaseClass.PerformLayout(self, w, h)
end

vgui.Register("ttt_settings", PANEL, "ttt_curved_panel")

function GM:ShowHelp()
	if (IsValid(ttt.settings)) then
		ttt.settings:Remove()
	else
		ttt.settings = vgui.Create "ttt_settings"
		ttt.settings:MakePopup()
		ttt.settings:SetKeyboardInputEnabled(false)
	end
end