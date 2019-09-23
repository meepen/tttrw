local PANEL = {}

function PANEL:AcceptInput(key, value)
	self.inputs = self.inputs or {}
	self.inputs[key] = value
	if (key == "bg_color") then
		self:SetColor(self:GetInputColor(key))
	elseif (key == "pos" or key == "size") then
		self:Recenter()
		return true
	elseif (key == "curve") then
		self:SetCurve(math.Round(ScrH() * value / 2) * 2)
	end
end

function PANEL:AnimationThink()
	self.color_inputs = self.color_inputs or {}
	for key, value in pairs(self.color_inputs) do
		local new = self:GetInputColor(key)
		if (new ~= value) then
			self:AcceptInput(key, new)
		end
	end
end

function PANEL:GetInputColor(key)
	self.color_inputs = self.color_inputs or {}
	
	local col

	local value = self.color_inputs[key]
	if (not value) then
		value = self.inputs[key]
		self.color_inputs[key] = value
	end

	if (not value) then
		col = white_text
	elseif (IsColor(value)) then
		col = value
	elseif (type(value) == "table") then
		col = Color(value[1], value[2], value[3], value[4])
	elseif (value == "role") then
		local targ = ttt.GetHUDTarget()
	
		if (IsValid(targ) and targ:Alive() and IsValid(targ.HiddenState) and not targ.HiddenState:IsDormant()) then
			col = ttt.roles[targ:GetRole()].Color
		else
			col = Color(154, 153, 153)
		end
	end

	self.inputs[key] = col

	return col
end

function PANEL:OnScreenSizeChanged()
	self:Recenter()
end

function PANEL:Recenter()
	self.inputs = self.inputs or {}
	local pos, size
	if (self.inputs.pos) then
		pos = {
			math.Round(self.inputs.pos[1] * ScrW()),
			math.Round(self.inputs.pos[2] * ScrH()),
			self.inputs.pos[3]
		}
	else
		pos = {self:GetPos()}
		pos[3] = self:GetZPos()
	end

	if (self.inputs.size) then
		size = {
			math.Round(self.inputs.size[1] * ScrW()),
			math.Round(self.inputs.size[2] * ScrH())
		}
	else
		size = {self:GetSize()}
	end

	self:SetPos(pos[1] - size[1] / 2, pos[2] - size[2] / 2)
	self:SetSize(size[1], size[2])
	self:SetZPos(pos[3])

	self:SetCurve(math.Round(ScrH() * (self.inputs.curve or 0.005) / 2) * 2)
end

vgui.Register("ttt_hud_customizable", PANEL, "ttt_curved_panel")
vgui.Register("ttt_curve", PANEL, "ttt_curved_panel")


local PANEL = table.Copy(PANEL)

function PANEL:AcceptInput(key, value)
	self.inputs = self.inputs or {}
	self.inputs[key] = value
	if (key == "bg_color") then
		self:SetColor(Color(value[1], value[2], value[3], value[4] or 255))
	elseif (key == "pos" or key == "size") then
		self:Recenter()
		return true
	elseif (key == "path") then
		self:SetImage(value)
	elseif (key == "color") then
		self:SetImageColor(Color(unpack(value)))
	end
end
function PANEL:Recenter()
	self.inputs = self.inputs or {}
	local pos, size
	if (self.inputs.pos) then
		pos = {
			math.Round(self.inputs.pos[1] * ScrW()),
			math.Round(self.inputs.pos[2] * ScrH()),
			self.inputs.pos[3]
		}
	else
		pos = {self:GetPos()}
		pos[3] = self:GetZPos()
	end

	if (self.inputs.size) then
		size = {
			math.Round(self.inputs.size[1] * ScrW()),
			math.Round(self.inputs.size[2] * ScrH())
		}
	else
		size = {self:GetSize()}
	end

	self:SetPos(pos[1] - size[1] / 2, pos[2] - size[2] / 2)
	self:SetSize(size[1], size[2])
	self:SetZPos(pos[3])
end

vgui.Register("ttt_image", PANEL, "DImage")

local PANEL = {}

function PANEL:PerformLayout()
	self:SetCurve(self:GetParent():GetCurve())
	self:DockPadding(self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2)
end
vgui.Register("ttt_curve_outline_inner", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self.Inner = self:Add "ttt_curve_outline_inner"
	self.Inner:Dock(FILL)
	self.Inner:SetZPos(0)
end

function PANEL:AcceptInput(key, value)
	self.BaseClass.AcceptInput(self, key, value)
	if (key == "outline_color") then
		self.Inner:SetColor(self:GetInputColor(key))
	end
end
vgui.Register("ttt_curve_outline", PANEL, "ttt_hud_customizable")