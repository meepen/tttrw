local PANEL = {}
ttt.ColorMaterials = ttt.ColorMaterials or {}

AccessorFunc(PANEL, "Curve", "Curve", FORCE_NUMBER)
AccessorFunc(PANEL, "Color", "Color")

for _, name in pairs {"CurveTopRight", "CurveTopLeft", "CurveBottomLeft", "CurveBottomRight"} do
	PANEL["Set" .. name] = function(self, v)
		self[name] = v
		if (IsValid(self.Mesh)) then
			self:RebuildMesh()
		end
	end

	PANEL[name] = true

	PANEL["GetNo" .. name] = function(self)
		return not self[name]
	end
end

function PANEL:SetColor(col)
	if (col ~= self.Color) then
		self.Color = col
		self:RebuildMesh()
	end
end

function PANEL:SetCurve(curve)
	self.Curve = curve
	self:RebuildMesh()
end

function PANEL:RebuildMesh(w, h)
	if (not w) then
		w, h = self:GetSize()
	end

	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
		self.Mesh = nil
	end

	local x, y = self:LocalToScreen(0, 0)

	self.Mesh = hud.BuildCurvedMesh(self:GetCurve() or 0, x, y, w, h, self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight(), self:GetColor() or color_white)
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

PANEL.GetRenderBounds = GetRenderBounds

function PANEL:SetScissor(b)
	self.DontScissor = not b
end

function PANEL:GetScissor()
	return not self.DontScissor
end

function PANEL:Scissor()
	if (not self:GetScissor()) then
		return
	end
	local x0, y0, x1, y1 = self:GetRenderBounds()
	render.SetScissorRect(x0, y0, x1, y1, true)
end

function PANEL:MeshRemove()
	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
	end

	if (self.OldRemove) then
		self:OldRemove()
	end
end

function PANEL:Paint(w, h)
	self.OldRemove = self.OldRemove or self.OnRemove or function() end
	self.OnRemove = self.MeshRemove

	local x, y = self:LocalToScreen(0, 0)
	if (self._OLDW ~= w or self._OLDH ~= h or self._OLDX ~= x or self._OLDY ~= y) then
		self:RebuildMesh(w, h)
		self._OLDW = w
		self._OLDH = h
		self._OLDX = x
		self._OLDY = y
	end

	self:Scissor()
	render.SetColorMaterial()
	self.Mesh:Draw()
	render.SetScissorRect(0, 0, 0, 0, false)
end

vgui.Register("ttt_curved_panel", PANEL, "EditablePanel")

local PANEL = table.Copy(PANEL)

vgui.Register("ttt_curved_button", table.Copy(PANEL), "DButton")

local PANEL = {}

function PANEL:RebuildMesh(w, h)
	if (IsValid(self.Mesh)) then
		self.Mesh:Remove()
		self.Mesh = nil
	end

	local x, y = self:LocalToScreen(0, 0)

	self.Mesh = hud.BuildCurvedMeshOutline(self:GetCurve() or 0, x, y, self:GetWide(), self:GetTall(), self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight(), self:GetColor())
end

vgui.Register("ttt_curved_panel_outline", PANEL, "ttt_curved_panel")