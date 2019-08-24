local PANEL = {}
ttt.ColorMaterials = ttt.ColorMaterials or {}

AccessorFunc(PANEL, "Curve", "Curve", FORCE_NUMBER)


for _, name in pairs {"CurveTopRight", "CurveTopLeft", "CurveBottomLeft", "CurveBottomRight"} do
    PANEL["Set" .. name] = function(self, v)
        self[name] = v
        self:RebuildMesh(self:GetSize())
    end

    PANEL[name] = true

    PANEL["GetNo" .. name] = function(self)
        return not self[name]
    end
end

function PANEL:SetColor(col)
    local num = col.r + col.g * 256 + col.b * 256 * 256 + col.a * 256 * 256 * 256

    self.Material = CreateMaterial("tttrw_mat_color" .. num, "UnlitGeneric", {
        ["$basetexture"] = "color/white",
        ["$color"] = string.format("{ %i %i %i }", col.r, col.g, col.b),
        ["$alpha"] = col.a / 255
    })
end

local SetCurve = PANEL.SetCurve

function PANEL:SetCurve(curve)
    SetCurve(self, curve)
    self:RebuildMesh(self:GetSize())
end

function PANEL:PerformLayout(w, h)
    self:RebuildMesh(w, h)

    self.Bounds = {self:GetRenderBounds()}
end

function PANEL:RebuildMesh(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(self:GetCurve(), 0, 0, w, h, self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight())
end

function PANEL:GetRenderBounds()
    local nx, ny = self:LocalToScreen(0, 0)
    local mx, my = nx + self:GetWide(), ny + self:GetTall()

    local parent = self:GetParent()

    while (IsValid(parent)) do
        local x, y = parent:LocalToScreen(0, 0)
        local w, h = parent:GetSize()
        nx = math.max(nx, x)
        ny = math.max(ny, y)
        mx = math.min(mx, x + w)
        my = math.min(my, y + h)
    
        parent = parent:GetParent()
    end

    return nx, ny, mx, my
end

function PANEL:Paint(w, h)
    if (not self.Material) then
        self:SetColor(color_white)
    end

    local scrx, scry = self:LocalToScreen(0, 0)
	hud.StartStenciledMesh(self.Mesh, scrx, scry)
        render.SetMaterial(self.Material)


        -- slow :(
        --local nx, ny, mx, my = self:GetRenderBounds()
        --render.SetScissorRect(nx, ny, mx, my, true)
        render.DrawScreenQuad()
        --render.SetScissorRect(0, 0, 0, 0, false)
	hud.EndStenciledMesh()
end

vgui.Register("ttt_curved_panel", PANEL, "EditablePanel")

local PANEL = table.Copy(PANEL)

vgui.Register("ttt_curved_button", table.Copy(PANEL), "DButton")