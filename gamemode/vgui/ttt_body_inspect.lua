local bg_color = CreateMaterial("ttt_body_inspect_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = Color(51, 51, 52)

surface.CreateFont("ttt_body_inspect_tab_font", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 400
})

surface.CreateFont("ttt_body_inspect_header_font", {
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

DEFINE_BASECLASS "ttt_curved_panel"

local function OnBodyInitialize(self, cb)
    if (not IsValid(ttt.InspectBody.HiddenState)) then
        hook.Add("BodyDataInitialized", self, function(self, e)
            timer.Simple(0, function()
                if (IsValid(self)) then
                    cb(self, e)
                end
            end)
        end)
    else
        cb(self, ttt.InspectBody.HiddenState)
    end
end

function PANEL:Init()
    self:SetCurve(5)
    self:SetColor(Color(41, 41, 42))

    local Padding = Padding / 2

    self:DockPadding(Padding, Padding, Padding, Padding)

    self.Header = self:Add "ttt_body_inspect_header"
    self.Header:SetText "LOADING!!!!"
    self.Header:DockPadding(0, 0, 0, Padding)
    self.Header:Dock(TOP)
    self.Header:SetZPos(0)

    self.CurrentElement = self:Add "ttt_body_inspect_current"
    self.CurrentElement:Dock(TOP)
    self.CurrentElement:SetZPos(2)

    self.Button = self:Add "ttt_curved_button"
    self.Button:SetFont "ttt_body_inspect_header_font"
    self.Button:SetText "Confirm Death"
    self.Button:SetCurve(4)
    self.Button:Dock(LEFT)
    self.Button:SetColor(Color(87, 90, 90))
    self.Button:SetTextColor(Color(177, 177, 177))
    self.Button:SetZPos(3)
    self.Button:DockMargin(Padding, Padding, Padding, 0)

    -- has to be last lol
    self.Icons = self:Add "ttt_body_inspect_icon_list"
    self.Icons:Dock(TOP)
    self.Icons:SetZPos(1)

    self:ResizeChildrenProperly()
end

function PANEL:ResizeChildrenProperly()
    local header = self.Header:GetTall()

    surface.SetFont(self.Button:GetFont())
    local _, h = surface.GetTextSize "A"
    local tall = self:GetTall() - Padding * 3.5 - h

    self.Icons:SetTall(tall / 5 * 2)
    self.CurrentElement:SetTall(tall / 5 * 2 + Padding)
    self.Button:SetTall(Padding + h)
end

function PANEL:PerformLayout(w, h)
    BaseClass.PerformLayout(self, w, h)

    self:ResizeChildrenProperly()
end

function PANEL:Select(var)
    self.Header:SetText(var:GetTitle())

    self.CurrentElement:SetVariable(var)
end

vgui.Register("ttt_body_inspect_body_inner", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self.Buttons = {}

    local Padding = Padding / 2

    self:DockMargin(0, Padding, Padding, Padding)

    OnBodyInitialize(self, self.BodyDataInitialized)
end

function PANEL:BodyDataInitialized(ent)
    if (ent:GetRagdoll() ~= ttt.InspectBody) then
        return
    end

    for i, var in ipairs(ent:GetData()) do
        self.Buttons[i] = self:Add "DImageButton"
        self.Buttons[i]:SetImage(var:GetIcon())
        self.Buttons[i]:Dock(LEFT)
        self.Buttons[i]:SetZPos(i)
        self.Buttons[i].DoClick = function()
            self:GetParent():Select(var)
        end
    end

    if (ent:GetData()[1]) then
        self:GetParent():Select(ent:GetData()[1])
    end
end


function PANEL:PerformLayout(w, h)
    for _, pnl in pairs(self:GetChildren()) do
        pnl:SetSize(h, h)
        pnl:DockMargin(Padding / 2, 0, 0, 0)
    end
end

vgui.Register("ttt_body_inspect_icon_list", PANEL, "EditablePanel")

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
    self.Icon:SetImage "materials/tttrw/disagree.png"
    self.Icon:DockMargin(0, 0, Padding, 0)

    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_body_inspect_header_font"
    self.Text:Dock(FILL)
    self.Text:SetZPos(1)
    self.Text:SetText "LOADING!!"
end

function PANEL:SetVariable(var)
    self.Variable = var
    self:Think()
end

function PANEL:Think()
    if (IsValid(self.Variable)) then
        local desc, image = self.Variable:GetDescription(), self.Variable:GetIcon()
        if (self.Description ~= desc) then
            self.Text:SetText(desc)
            self.Description = desc
        end
        if (self.Image ~= image) then
            self.Icon:SetImage(image)
            self.Image = image
        end
    end
end

function PANEL:PerformLayout(w, h)
    BaseClass.PerformLayout(self, w, h)

    self.Icon:SetSize(h - Padding, h - Padding)
end

vgui.Register("ttt_body_inspect_current", PANEL, "ttt_curved_panel")

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

    return pnl
end

vgui.Register("ttt_body_inspect_tab_holder", PANEL, "EditablePanel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self:SetText "a"
    self:SetFont "ttt_body_inspect_header_font"
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

vgui.Register("ttt_body_inspect_header", PANEL, "ttt_curved_panel")


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
    self:SetBody(ttt.InspectBody)
    self.Close = self:Add "ttt_close_button"
    self.Close:SetZPos(1)
    self.Close:SetColor(Color(37, 173, 125))

    self.Inner = self:Add "ttt_body_inspect_body"
    self.Inner:Dock(FILL)
    self.Tabs = self:Add "ttt_body_inspect_tab_holder"
    self.Tabs:SetHeight(Padding)
    self.Tabs:Dock(TOP)
    self.Tabs:SetTall(ScrH() * 0.02)
    self.MainTab = self.Tabs:AddTab "Body Search Results"
    self:DockPadding(Padding, Padding, Padding, Padding)

    self:SetColor(Color(13, 12, 13, 240))
    self:SetCurve(3)

    hook.Add("KeyPress", self, self.KeyPress)

    
    OnBodyInitialize(self, self.BodyDataInitialized)
end

function PANEL:BodyDataInitialized(ent)
    self.MainTab:SetText(ent:GetNick() .. "'s body")
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