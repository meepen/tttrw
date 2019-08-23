local bg_color = CreateMaterial("ttt_body_inspect_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = CreateMaterial("ttt_body_normal" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
    ["$color"] = "{ 51 51 52 }",
})

local ttt_body_darken = CreateMaterial("ttt_body_darken" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
    ["$color"] = "{ 41 41 42 }",
})

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
    self:DockPadding(Padding, Padding, Padding, Padding)
end

function PANEL:PerformLayout(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(5, 0, 0, w, h, true)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(ttt_body_normal)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

vgui.Register("ttt_body_inspect_body", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:PerformLayout(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(5, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(ttt_body_darken)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

vgui.Register("ttt_body_inspect_body_inner", PANEL, "EditablePanel")

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

function PANEL:Init()
    self.Text = self:Add "DLabel"
    self.Text:SetFont "ttt_body_inspect_tab_font"
    self:SetText("a")
end

function PANEL:PerformLayout(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Text:SizeToContents()
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())

    self.Mesh = hud.BuildCurvedMesh(5, 0, 0, w, h, false, false, true, true)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(ttt_body_normal)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

function PANEL:SetText(t)
    self.Text:SetText(t)
    self.Text:SizeToContents()
    self:SetWide(self.Text:GetWide() + Padding * 2)
    self.Text:SetPos(self:GetWide() / 2 - self.Text:GetWide() / 2, self:GetTall() - self.Text:GetTall())
end

vgui.Register("ttt_body_inspect_tab", PANEL, "EditablePanel")

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
    print(_, endy)
    local rounded2 = math.Round(endy / 2)
    self.Close:SetSize(rounded2, rounded2)
    self.Close:SetPos(w - self.Close:GetWide() - rounded2 / 2, rounded2 / 2)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(4, 0, 0, w, h)
end

function PANEL:Paint(w, h)
	hud.StartStenciledMesh(self.Mesh, self:LocalToScreen(0, 0))
		render.SetMaterial(bg_color)
		render.DrawScreenQuad()
	hud.EndStenciledMesh()
end

vgui.Register("ttt_body_inspect", PANEL, "EditablePanel")