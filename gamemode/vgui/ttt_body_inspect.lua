local bg_color = CreateMaterial("ttt_body_inspect_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = Color(51, 51, 52)

surface.CreateFont("ttt_body_inspect_tab_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 200
})

local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
    self.Inner = self:Add "ttt_body_inspect_body_inner"
    self.Inner:Dock(FILL)
    self:SetCurve(5)
    self:SetColor(ttt_body_normal)
    self:DockPadding(Padding, Padding, Padding, Padding)
    self:SetCurveTopLeft(false)
end

vgui.Register("ttt_body_inspect_body", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self:SetCurve(5)
    self:SetColor(Color(41, 41, 42))
end

vgui.Register("ttt_body_inspect_body_inner", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Tabs = {}
end

function PANEL:AddTab(text)
    local pnl = self:Add "ttt_body_inspect_tab"
    pnl:SetZPos(0x7fff - #self.Tabs)
    pnl:Dock(LEFT)
    pnl:SetText(text)

    table.insert(self.Tabs, pnl)
end

vgui.Register("ttt_body_inspect_tab_holder", PANEL, "EditablePanel")


local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_body_inspect_tab_font"
    self:SetText "a"
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

vgui.Register("ttt_body_inspect_tab", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Close = self:Add "ttt_close_button"
    self.Close:SetZPos(1)
    self.Close:SetColor(Color(37, 173, 125))

    self.Inner = self:Add "ttt_body_inspect_body"
    self.Inner:Dock(FILL)
    self.Tabs = self:Add "ttt_body_inspect_tab_holder"
    self.Tabs:SetHeight(Padding)
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(ScrH() * 0.02)
    self.Tabs:AddTab "Body Search Results"
    self:DockPadding(Padding, Padding, Padding, Padding)

    self:SetColor(Color(13, 12, 13, 240))
    self:SetCurve(3)

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

function PANEL:Think()
    if (not IsValid(self.Body) or LocalPlayer():GetPos():Distance(self.Position) > self.MaxDistance) then
        self:Remove()
    end
end
    

function PANEL:PerformLayout(w, h)
    local _, endy = self:ScreenToLocal(self.Tabs:LocalToScreen(0, self.Tabs:GetTall()))
    local rounded2 = math.Round(endy / 2)
    self.Close:SetSize(rounded2, rounded2)
    self.Close:SetPos(w - self.Close:GetWide() - rounded2 / 2, rounded2 / 2)
    
    BaseClass.PerformLayout(self, w, h)
end

function PANEL:SetBody(body)
    self.Body = body
end

vgui.Register("ttt_body_inspect", PANEL, "ttt_curved_panel")