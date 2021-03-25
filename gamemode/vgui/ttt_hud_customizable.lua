ttt.hud = {
	elements = {},
	text = {},
	functions = {},
	inputs = {},
}


local function SetJSON(self, json)
	if (not istable(json)) then
		return "json not readable"
	end

	for key, value in pairs(json) do
		local fn = self.Inputs["Set" .. key]
		if (not fn) then
			fn = self.Inputs["Set" .. key:sub(1, 1):upper() .. key:sub(2)]
		end

		if (not fn) then
			return "unknown input: " .. key
		end

		local err = fn(self, value)
		if (err) then
			return err
		end
	end

	self.TTTRWHUDElement = json
end

function ttt.hud.registerelement(element, inputs, base, vgui_element)
	ttt.hud.elements[element] = {
		Name = element,
		Inputs = inputs,
		Parent = parent,
		VGUIElement = vgui_element or base and "tttrw_hud_" .. base or "EditablePanel"
	}

	inputs.CustomizeBase = base

	setmetatable(inputs, {
		__index = function(self, k)
			local base = rawget(self, "CustomizeBase")
			if (base and ttt.hud.elements[base]) then
				return ttt.hud.elements[base].Inputs[k]
			end
		end
	})

	inputs.TTTRWHUDElement = true

	vgui.Register("tttrw_hud_" .. element, {
		Inputs = inputs,
		TTTRWHUDName = element,
		SetJSON = SetJSON
	}, ttt.hud.elements[element].VGUIElement)
end

function ttt.hud.create(data, parent)
	if (not ttt.hud.elements[data.element]) then
		return "no such element: " .. tostring(data.element)
	end

	print("[TTTRW HUD]: Creating element " .. (data.name or data.element))


	if (ttt.hud.elements[data.element].Inputs.GetCustomizeParent) then
		parent = ttt.hud.elements[data.element].Inputs.GetCustomizeParent(parent)
	end

	local ele = vgui.Create("tttrw_hud_" .. data.element, parent)
	local err = ele:SetJSON(data)
	if (err) then
		ele:Remove()

		return false, err
	end
	ele.TTTRWHUDParent = parent
	ele:SetMouseInputEnabled(true)
	return ele
end

function ttt.hud.createfunction(name, func)
	ttt.hud.functions[name] = func
end

function ttt.hud.createinput(name, func)
	ttt.hud.inputs["$$" .. name] = func
end

function ttt.hud.getvalue(data)
	if (IsColor(data)) then
		return data
	elseif (istable(data)) then
		local func = ttt.hud.functions[data.func]
		if (isfunction(func)) then
			local args = {n = 0}
			if (data.inputs) then
				args = {n = #data.inputs, unpack(data.inputs)}
				for i = 1, args.n do
					args[i] = ttt.hud.getvalue(args[i]) or args[i]
				end
			end

			return func(unpack(args, 1, args.n))
		end

		if (#data == 3 or #data == 4) then
			return Color(unpack(data))
		end
	elseif (isstring(data)) then
		if (data:StartWith "$$") then
			local func = ttt.hud.inputs[data]
			if (func) then
				return func()
			end
		end

		if (data:StartWith "#") then
			local col = HexColor(data)
			if (col) then
				return col
			end
		end
	end

	return tonumber(data) or data
end

--[[
	DEFAULT FUNCTIONS
]]

ttt.hud.createfunction("lerp", function(pct, ...)
	local amount = select("#", ...)

	pct = ttt.hud.getvalue(pct)
	print(pct)

	if (pct >= 1) then
		return ttt.hud.getvalue(select(amount, ...))
	elseif (pct <= 0) then
		return ttt.hud.getvalue((...))
	end

	local curindex = pct / (1 / (amount - 1))

	local before, after = select(math.floor(curindex) + 1, ...)
	before, after = ttt.hud.getvalue(before), ttt.hud.getvalue(after)

	local frac = curindex % (1 / (amount - 1))

	local Lerp = Lerp
	if (IsColor(before)) then
		Lerp = ColorLerp
	end

	return Lerp(frac, before, after)
end)

ttt.hud.createfunction("divide", function(a, b)
	return ttt.hud.getvalue(a) / ttt.hud.getvalue(b)
end)

ttt.hud.createfunction("concat", function(...)
	local data = {n = select("#", ...), ...}
	for i = 1, data.n do
		data[i] = ttt.hud.getvalue(data[i])
	end
	return table.concat(data, "", 1, data.n)
end)


ttt.hud.createfunction("uppercase", function(a)
	return ttt.hud.getvalue(a):upper()
end)

ttt.hud.createfunction("add", function(a, b)
	return ttt.hud.getvalue(a) + ttt.hud.getvalue(b)
end)

ttt.hud.createfunction("sub", function(a, b)
	return ttt.hud.getvalue(a) - ttt.hud.getvalue(b)
end)

ttt.hud.createfunction("coloralpha", function(col, alpha)
	alpha = ttt.hud.getvalue(alpha)
	col = ttt.hud.getvalue(col)

	return ColorAlpha(col, alpha)
end)

ttt.hud.createinput("gunname", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end
	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep)) then
		return ""
	end

	return wep:GetPrintName()
end)

ttt.hud.createinput("guncolor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(255, 255, 255)
	end
	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep)) then
		return Color(255, 255, 255)
	end

	return wep:GetPrintNameColor()
end)

ttt.hud.createinput("gunammo", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end
	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep)) then
		return 0
	end

	return wep:Clip1() == -1 and 0 or wep:Clip1()
end)

ttt.hud.createinput("gunreserves", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end
	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep)) then
		return 0
	end

	return targ:GetAmmoCount(wep:GetPrimaryAmmoType())
end)

ttt.hud.createinput("health", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:Health()
end)

ttt.hud.createinput("maxhealth", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:GetMaxHealth()
end)

ttt.hud.createinput("rolecolor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(0, 0, 0)
	end

	return targ:GetRoleData().Color
end)

ttt.hud.createinput("armor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(0, 0, 0)
	end

	return targ:Armor()
end)

ttt.hud.createinput("maxarmor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:GetMaxArmor()
end)

ttt.hud.createinput("rolename", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:GetRoleData().Name
end)

ttt.hud.createinput("teamcolor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(0, 0, 0)
	end

	return targ:GetRoleTeamData().Color
end)

ttt.hud.createinput("teamname", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:GetRoleTeamData().Name
end)

ttt.hud.createinput("roleicon", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:GetRoleData().DeathIcon or ""
end)

ttt.hud.createinput("roundstate", function()
	return ttt.Enums.RoundState[ttt.GetRoundState()]
end)

ttt.hud.createinput("timeleft", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	local timeleft = ttt.GetVisibleRoundEndTime() - CurTime()

	if (timeleft <= 0) then
		return ""
	end

	local text = {}
	if (timeleft >= 0) then
		local seconds = timeleft % 60
		text[1] = string.format("%02i", math.floor(seconds))
		timeleft = math.floor(timeleft / 60)
	end

	if (timeleft >= 0) then
		local minutes = timeleft % 60
		table.insert(text, 1, minutes)

		timeleft = math.floor(timeleft / 60)
	end

	if (timeleft > 0) then
		local hours = timeleft % 24
		text[1] = string.format("%02i", text[1])
		table.insert(text, 1, hours)

		timeleft = math.floor(timeleft / 24)
	end

	return table.concat(text, ":")
end)

ttt.hud.createinput("overtime", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ) or not targ:GetRoleData().Evil or ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
		return ""
	end

	local timeleft = ttt.GetRealRoundEndTime() - CurTime()

	if (timeleft <= 0) then
		return ""
	end

	local text = {}
	if (timeleft >= 0) then
		local seconds = timeleft % 60
		text[1] = string.format("%02i", math.ceil(seconds))
		timeleft = math.floor(timeleft / 60)
	end

	if (timeleft >= 0) then
		local minutes = timeleft % 60
		table.insert(text, 1, minutes)

		timeleft = math.floor(timeleft / 60)
	end

	if (timeleft > 0) then
		local hours = timeleft % 24
		text[1] = string.format("%02i", text[1])
		table.insert(text, 1, hours)

		timeleft = math.floor(timeleft / 24)
	end

	return table.concat(text, ":")
end)


local INPUTS = {}

function INPUTS:SetSize(array)
	if (not istable(array)) then
		return "not array"
	end

	local w, h = ttt.hud.getvalue(array[1]), ttt.hud.getvalue(array[2])

	if (not w) then
		return "no width"
	end

	if (not h) then
		return "no height"
	end

	self:SetSize(w, h)
end

function INPUTS:RetrieveInputMethod(method)
	local class = self.ClassName
	while (class and class:StartWith "tttrw_hud_") do
		local t = vgui.GetControlTable(class)
		if (t[method]) then
			return t[method]
		end

		class = t.Base
	end
end

function INPUTS:SetElement()
end

function INPUTS:GetCustomizeParent()
	return self
end

function INPUTS:SetChildren(data)
	for _, childdata in ipairs(data) do
		local ele, err = ttt.hud.create(childdata, self)
		if (not ele) then
			return err
		end
	end
end

function INPUTS:SetName(name)
	self:SetName(name)
end

local docks = {
	fill = FILL,
	left = LEFT,
	top = TOP,
	right = RIGHT,
	bottom = BOTTOM
}

function INPUTS:SetDock(dock)
	if (docks[dock]) then
		self:Dock(docks[dock])
		return
	end

	return "no such dock: " .. dock
end

local transform = {
	right = function(x, y, w, h)
		return ScrW() - x - w, y, w, h
	end,
	left = function(x, y, w, h)
		return x, y, w, h
	end,
	top = function(x, y, w, h)
		return x, y, w, h
	end,
	bottom = function(x, y, w, h)
		return x, ScrH() - y - h, w, h
	end
}

function INPUTS:SetPositioning(dat)
	if (not istable(dat)) then
		return "invalid arguments"
	end
	local x, y = 0, 0

	if (istable(dat.offset)) then
		x, y = ttt.hud.getvalue(dat.offset[1]), ttt.hud.getvalue(dat.offset[2])
	end

	local w, h = 16, 16


	if (istable(dat.size)) then
		w, h = ttt.hud.getvalue(dat.size[1]), ttt.hud.getvalue(dat.size[2])
	end

	if (dat.from) then
		if (isstring(dat.from)) then
			dat.from = dat.from:Split " "
		end

		for _, from in ipairs(dat.from) do
			if (not transform[from]) then
				return "invalid transform: " .. from
			end

			x, y, w, h = transform[from](x, y, w, h)
		end
	end

	self:SetPos(x, y)
	self:SetSize(w, h)
end

function INPUTS:SetFrameupdate(arr)
	if (not istable(arr)) then
		return "invalid frameupdate input"
	end

	hook.Add("PreRender", self, function()
		for _, key in ipairs(arr) do
			local value = ttt.hud.getvalue(self.TTTRWHUDElement[key])

			local fn = self.Inputs["Set" .. key]
			if (not fn) then
				fn = self.Inputs["Set" .. key:sub(1, 1):upper() .. key:sub(2)]
			end
	
			if (not fn) then
				return "unknown input: " .. key
			end
	
			local err = fn(self, value)
			if (err) then
				warn("%s", err)
			end
		end
	end)
end

function INPUTS:SetPadding(arr)
	if (isnumber(arr)) then
		arr = {arr, arr, arr, arr}
	end

	if (not istable(arr)) then
		return "invalid padding"
	end

	self:DockPadding(unpack(arr))
end

function INPUTS:SetMargin(arr)
	if (isnumber(arr)) then
		arr = {arr, arr, arr, arr}
	end

	if (not istable(arr)) then
		return "invalid padding"
	end

	self:DockMargin(unpack(arr))
end

function INPUTS:SetSizeto(what)
	if (what == "contents") then
		self:SizeToContents()
	elseif (what == "children") then
		self:SizeToChildren(true, true)
	elseif (istable(what)) then
		if (what.what == "children") then
			self:SizeToChildren(what.width, what.height)
		end
	end
end

function INPUTS:SetCenter(b)
	self:Center()
end

ttt.hud.registerelement("base", INPUTS)


local INPUTS = {}

function INPUTS:SetColor(arr)
	self:SetColor(ttt.hud.getvalue(arr))
end

function INPUTS:SetCurve(curve)
	if (curve == "inherit") then
		self:SetCurve(self:GetParent():GetCurve())
	else
		self:SetCurve(ttt.hud.getvalue(curve))
	end
end

function INPUTS:SetScissor(arr)
	function self:Scissor(w, h)
		local sx, sy = ttt.hud.getvalue(arr[1]), ttt.hud.getvalue(arr[2])
	
		if (#arr > 2) then
			w, h = w - w * ttt.hud.getvalue(arr[3]), h - h * ttt.hud.getvalue(arr[4])
		end

		sx, sy = self:LocalToScreen(sx, sy)

		render.SetScissorRect(sx, sy, sx + w, sy + h, true)
	end
end


ttt.hud.registerelement("curve", INPUTS, "base", "ttt_curved_panel")

local INPUTS = {}

function INPUTS:SetOutlinesize(size)
	self:SetOutlineSize(size)
end

ttt.hud.registerelement("curve_outline", INPUTS, "curve", "ttt_curved_panel_outline")

local INPUTS = {}

function INPUTS:SetContentalignment(align)
	self:SetContentAlignment(align)
end

function INPUTS:SetFont(font)

	local fontdata = {}
	for key, value in SortedPairs(font) do
		fontdata[#fontdata + 1] = key
		fontdata[#fontdata + 1] = tostring(value)
	end

	local name = "tttrw_font" .. util.CRC(table.concat(fontdata))

	surface.CreateFont(name, font)

	self:SetFont(name)
end

function INPUTS:SetRendersystem(system)
	if (not pluto) then
		return
	end

	self:SetRenderSystem(pluto.fonts.systems[system])
end

function INPUTS:SetColor(arr)
	self:SetTextColor(ttt.hud.getvalue(arr))
end

function INPUTS:SetText(text)
	self:SetText(ttt.hud.getvalue(text))
	self:SizeToContentsX()
end

ttt.hud.registerelement("label", INPUTS, "base", "tttrw_label")

local PANEL = {}

function PANEL:Paint(w, h)
	local mat = self:GetMaterial()
	mat:SetVector("$color", self:GetImageColor():ToVector())
	mat:SetFloat("$alpha", self:GetImageColor().a / 255)
	surface.SetMaterial(self:GetMaterial())
	surface.SetDrawColor(255, 255, 255)
	if (self.Reverse) then
		surface.DrawTexturedRectUV(0, 0, w, h, 1, 0, 0, 1)
	else
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

vgui.Register("tttrw_hud_dimage", PANEL, "DImage")

local INPUTS = {}

function INPUTS:SetImage(img)
	img = ttt.hud.getvalue(img)
	if (self.ImageName ~= img) then
		self:SetMaterial(Material(img, "nocull smooth"))
		self.ImageName = img
	end
end

function INPUTS:SetReverse()
	self.Reverse = true
end

function INPUTS:SetColor(col)
	col = ttt.hud.getvalue(col)
	self:SetImageColor(col)
end

ttt.hud.registerelement("image", INPUTS, "base", "tttrw_hud_dimage")