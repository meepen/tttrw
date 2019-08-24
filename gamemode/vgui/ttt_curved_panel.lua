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
end

function PANEL:RebuildMesh(w, h)
    if (IsValid(self.Mesh)) then
        self.Mesh:Remove()
        self.Mesh = nil
    end

    self.Mesh = hud.BuildCurvedMesh(self:GetCurve(), 0, 0, w, h, self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight())
end

local memoize = {}

hook.Add("PostRenderVGUI", "ttt_curved_panel", function()
    memoize = {}
end)

local function GetRenderBounds(self)
    local m = memoize[self]
    if (m ~= nil) then
        return m[1], m[2], m[3], m[4]
    end

    local x0, y0 = self:LocalToScreen(0, 0)
    local x1, y1 = self:LocalToScreen(self:GetSize())

    local parent = self:GetParent()

    if (IsValid(parent)) then
        local px0, py0, px1, py1 = GetRenderBounds(parent)
        x0 = math.max(x0, px0)
        y0 = math.max(y0, py0)
        x1 = math.min(x1, px1)
        y1 = math.min(y1, py1)
    end

    memoize[self] = {x0, y0, x1, y1}

    return x0, y0, x1, y1
end

function PANEL:Paint(w, h)
    if (not self.Material) then
        self:SetColor(color_white)
    end

    local scrx, scry = self:LocalToScreen(0, 0)
	hud.StartStenciledMesh(self.Mesh, scrx, scry)
        render.SetMaterial(self.Material)

        local x0, y0, x1, y1 = GetRenderBounds(self)
        render.SetScissorRect(x0, y0, x1, y1, true)
        render.DrawScreenQuad()
        render.SetScissorRect(0, 0, 0, 0, false)
	hud.EndStenciledMesh()
end

vgui.Register("ttt_curved_panel", PANEL, "EditablePanel")

local PANEL = table.Copy(PANEL)

vgui.Register("ttt_curved_button", table.Copy(PANEL), "DButton")