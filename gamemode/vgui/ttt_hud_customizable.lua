local PANEL = {}

local docks = {
	fill = FILL,
	right = RIGHT,
	left = LEFT,
	top = TOP,
	bottom = BOTTOM
}

function PANEL:AcceptInput(key, value)
	self.inputs = self.inputs or {}
	self.inputs[key] = value
	if (key == "bg_color") then
		self:SetColor(self:GetInputColor(key))
	elseif (key == "pos" or key == "size" or key == "padding") then
		self:Recenter()
		return true
	elseif (key == "dock") then
		self:Dock(docks[value])
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

function PANEL:GetCustomizeParent()
	return self
end

function PANEL:GetInputColor(key)
	self.color_inputs = self.color_inputs or {}

	local value = self.color_inputs[key]
	if (not value) then
		value = self.inputs[key]
		self.color_inputs[key] = value
	end
	
	local col = self:GetCustomizedColor(value)

	self.inputs[key] = col

	return col
end

local color_functions = {
	lerp = function(self, data)
		local frac, from, to = math.Clamp(self:GetCustomizedNumber(data.frac), 0, 1)

		local count = #data.points

		for ind = count - 1, 1, -1 do
			local col = data.points[ind]
			local base = (ind - 1) / (count - 1)

			if (base <= frac) then
				from, to = self:GetCustomizedColor(data.points[ind]), self:GetCustomizedColor(data.points[ind + 1])
				frac = (frac - base) * count
				break
			end
		end

		return Color(Lerp(frac, from.r, to.r), Lerp(frac, from.g, to.g), Lerp(frac, from.b, to.b), Lerp(frac, from.a, to.a))
	end
}

local static_colors = {
	white = white_text,
	black = Color(11, 12, 11),
	black_bg = Color(11, 12, 11, 200)
}

function PANEL:GetCustomizedColor(value)
	local col
	
	if (not value) then
		col = white_text
	elseif (static_colors[value]) then
		col = static_colors[value]
	elseif (IsColor(value)) then
		col = value
	elseif (type(value) == "table") then
		if (value.func and color_functions[value.func]) then
			col = color_functions[value.func](self, value)
		else
			col = Color(
				self:GetCustomizedNumber(value[1]) or value[1],
				self:GetCustomizedNumber(value[2]) or value[2],
				self:GetCustomizedNumber(value[3]) or value[3],
				self:GetCustomizedNumber(value[4]) or value[4] or 255
			)
		end
	elseif (value == "role") then
		if (ttt.GetRoundState and ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
			col = Color(154, 153, 153)
		else

			local targ = ttt.GetHUDTarget()
		
			if (IsValid(targ) and targ:Alive() and IsValid(targ.HiddenState) and not targ.HiddenState:IsDormant()) then
				col = ttt.roles[targ:GetRole()].Color
			else
				col = Color(154, 153, 153)
			end
		end
	end

	return col
end

local number_functions = {
	lerp = function(self, data)
		return Lerp(data.frac, self:GetCustomizedNumber(data.from), self:GetCustomizedNumber(data.to))
	end,
	health_frac = function(self)
		local targ = ttt.GetHUDTarget()
		if (not IsValid(targ) or not targ:Alive()) then
			return 0
		end

		return targ:Health() / targ:GetMaxHealth()
	end,
	health = function()
		local targ = ttt.GetHUDTarget()
		if (not IsValid(targ)) then
			return 0
		end
		return math.max(0, targ:Health())
	end,
	health_max = function()
		local targ = ttt.GetHUDTarget()
		if (not IsValid(targ)) then
			return 0
		end
		return targ:GetMaxHealth()
	end
}

local text_functions = {
	time_remaining_pretty = function(self)
		if (ttt.GetRealRoundEndTime) then
			local ends = ((not LocalPlayer():Alive() or LocalPlayer():GetRoleData().Evil) and ttt.GetRealRoundEndTime or ttt.GetVisibleRoundEndTime)()
			local starts = ttt.GetRoundStateChangeTime()

			if (ends < CurTime()) then
				return "Overtime"
			else
				return string.FormattedTime(math.max(0, ends - CurTime()), "%i:%02i")
			end
		end
	end,
	role_name = function(self)
		if (ttt.GetRoundState and ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
			return ttt.Enums.RoundState[ttt.GetRoundState()]
		end
		
		local targ = ttt.GetHUDTarget()

		if (IsValid(targ) and targ:Alive() and IsValid(targ.HiddenState) and not targ.HiddenState:IsDormant()) then
			return targ:GetRole()
		elseif (ttt.GetRoundState) then
			return ttt.Enums.RoundState[ttt.GetRoundState()]
		else
			return "DUNNO"
		end
	end
}

function PANEL:GetCustomizedNumber(value)
	local ret

	if (type(value) == "table" and value.func) then
		ret = number_functions[value.func](self, value)
	elseif (type(value) == "string" and number_functions[value]) then
		ret = number_functions[value](self)
	end

	return ret
end

function PANEL:OnScreenSizeChanged()
	self:Recenter()
end

function PANEL:Recenter()
	self.inputs = self.inputs or {}
	local pos, size
	if (self.inputs.pos) then
		pos = {
			math.Round(self.inputs.pos[1] * self:GetParent():GetWide()),
			math.Round(self.inputs.pos[2] * self:GetParent():GetTall()),
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

	if (self.DoPadding and self.inputs.padding) then
		self:DoPadding(unpack(self.inputs.padding, 1, 4))
	end

	if (self.SetCurve) then
		self:SetCurve(math.Round(ScrH() * (self.inputs.curve or 0.005) / 2) * 2)
	end
end

function PANEL:DoPadding(left, top, right, bottom)
	local p = self:GetCustomizeParent()
	local c = (p.GetCurve and p:GetCurve() or 0) / 2
	p:DockPadding(c + left * p:GetWide(), c + top * p:GetTall(), c + right * p:GetWide(), c + bottom * p:GetTall())
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

vgui.Register("ttt_image", PANEL, "DImage")

local PANEL = {}

function PANEL:PerformLayout()
	local p = self:GetParent():GetParent()
	p:DoPadding(unpack(p.inputs.padding or {0, 0, 0, 0}, 1, 4))
end

function PANEL:GetFraction()
	local frac = self:GetParent():GetParent().inputs.frac
	return frac and self:GetParent():GetParent():GetCustomizedNumber(frac) or 1
end

function PANEL:Scissor()
	local x0, y0, x1, y1 = self:GetRenderBounds()
	local w = math.min(x1 - x0, self:GetWide() * self:GetFraction())
	render.SetScissorRect(x0, y0, x0 + w, y1, true)
end

vgui.Register("ttt_curve_outline_inner", PANEL, "ttt_curved_panel")

DEFINE_BASECLASS "ttt_hud_customizable"
local PANEL = table.Copy(BaseClass)

function PANEL:Init()
	self.Outer = self:Add "ttt_curved_panel_outline"
	self.Outer:Dock(FILL)
	self.Outer:SetZPos(0)

	self.Inner = self.Outer:Add "ttt_curve_outline_inner"
	self.Inner:Dock(FILL)
	self.Inner:SetZPos(0)
end

function PANEL:OnScreenSizeChanged()
	self:Recenter()
end

function PANEL:AcceptInput(key, value)
	self.inputs = self.inputs or {}
	self.inputs[key] = value
	if (key == "outline_color") then
		self.Outer:SetColor(self:GetInputColor(key))
	elseif (key == "bg_color") then
		self.Inner:SetColor(self:GetInputColor(key))
	elseif (key == "curve") then
		value = math.Round(ScrH() * (self.inputs.curve or 0.005) / 2) * 2
		self.Outer:SetCurve(value)
		self.Inner:SetCurve(value / 2)
		self.Outer:DockPadding(value / 2, value / 2, value / 2, value / 2)
	else
		BaseClass.AcceptInput(self, key, value)
	end
end

function PANEL:GetCustomizeParent()
	return self.Inner
end

vgui.Register("ttt_curve_outline", PANEL, "EditablePanel")


DEFINE_BASECLASS "ttt_hud_customizable"
local PANEL = table.Copy(BaseClass)

local alignments = {
	topleft = 7,
	top = 8,
	topright = 9,
	left = 4,
	middle = 5,
	right = 6,
	bottomleft = 1,
	bottom = 2,
	bottomright = 3
}

function PANEL:AcceptInput(key, value)
	self.inputs = self.inputs or {}
	self.inputs[key] = value

	if (key == "font") then
		self:RecreateFont()
	elseif (key == "align") then
		self:SetContentAlignment(alignments[value])
	else
		BaseClass.AcceptInput(self, key, value)
	end
end

function PANEL:Init()
	self:SetContentAlignment(5)
end

function PANEL:Think()
	local data = {}
	for i, inp in ipairs(self.inputs.text) do
		data[i] = self:GetCustomizedNumber(inp) or text_functions[inp] and text_functions[inp](self) or inp
	end

	data[1] = self.inputs.text[1]

	self:SetText(string.format(unpack(data)))
end

function PANEL:RecreateFont()
	local data = table.Copy(self.inputs.font)
	data.size = data.size * ScrH()
	surface.CreateFont(self:GetName() .. "_font", data)
	self:SetFont(self:GetName() .. "_font")
end

function PANEL:OnScreenSizeChanged()
	self:RecreateFont()
	self:Recenter()
end
	

vgui.Register("ttt_text", PANEL, "DLabel")