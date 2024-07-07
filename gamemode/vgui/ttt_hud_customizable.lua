ttt.hud = {
	elements = {},
	text = {},
	functions = {},
	inputs = {},
	features = {},
	current = nil,
	fonts = {},
	bases = {},
}

local function Update(self, key)
	local value = self.TTTRWHUDElement[key]

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

local function Set(self, key, value)
	self.TTTRWHUDElement[key] = value
	if (not value) then
		return
	end

	return Update(self, key)
end

local function Get(self, key)
	return self.TTTRWHUDElement[key]
end

local function SetJSON(self, json)
	if (not istable(json)) then
		return "json not readable"
	end

	self.TTTRWHUDElement = json

	for key, value in pairs(json) do
		local err = self:Set(key, value)
		if (err) then
			return err
		end
	end
end

local function GetEditableParent(self)
	local p = self:GetParent()
	while (IsValid(p)) do
		if (p.TTTRWHUDElement) then
			break
		end

		p = p:GetParent()
	end

	if (IsValid(p) and p.TTTRWHUDElement) then
		return p
	end
end

function ttt.hud.createfont(font, fontname)
	if (ttt.hud.fonts[font]) then
		return ttt.hud.fonts[font]
	end

	local fontdata = {}
	for key, value in SortedPairs(font) do
		fontdata[#fontdata + 1] = key
		fontdata[#fontdata + 1] = tostring(value)
	end

	local name = "tttrw_font" .. util.CRC(table.concat(fontdata))

	surface.CreateFont(name, font)
	if (fontname) then
		ttt.hud.fonts["$$" .. fontname] = name
	end

	return name
end

function ttt.hud.addfeature(feature)
	ttt.hud.features[feature] = true
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
			local base = ttt.hud.elements[rawget(self, "CustomizeBase")]
			if (base) then
				base = base.Inputs
			end

			if (k == "list") then
				local r = {}
				for kk in pairs(self) do
					r[kk] = true
				end

				if (base) then
					for kk in pairs(base.list or {}) do
						r[kk] = true
					end
				end

				return r
			end

			if (base) then
				return base[k]
			end
		end
	})

	vgui.Register("tttrw_hud_" .. element, {
		Inputs = inputs,
		TTTRWHUDName = element,
		Set = Set,
		Update = Update,
		SetJSON = SetJSON,
		GetEditableParent = GetEditableParent
	}, ttt.hud.elements[element].VGUIElement)
end

function ttt.hud.init(json)
	ttt.hud.current = json
	ttt.hud.bases = {}

	-- fonts
	if (json.variables) then
		for font, data in pairs(json.variables) do
			if (istable(data) and data.font) then
				ttt.hud.createfont(data, font)
			end
		end
	end

	if (IsValid(ttt.HUDElement)) then
		ttt.HUDElement:Remove()
	end

	ttt.HUDElement = vgui.Create "EditablePanel"
	ttt.HUDElement:SetParent(GetHUDPanel())
	ttt.HUDElement:SetSize(ScrW(), ScrH())

	for id, data in ipairs(json.elements) do
		local p, err = ttt.hud.create(data, ttt.HUDElement)
		if (not p or err) then
			print(err)
		end
		if (p) then
			table.insert(ttt.hud.bases, p)
		end
	end
end

local function remove_if_error(ele, err)
	if (err) then
		ele:Remove()

		return false, err
	end
	ele.TTTRWHUDParent = parent
	ele:SetMouseInputEnabled(true)
	return ele
end

function ttt.hud.create(data, parent)
	if (not ttt.hud.elements[data.element]) then
		return false, "no such element: " .. tostring(data.element)
	end

	if (data.requires) then
		if (isstring(data.requires)) then
			data.requires = data.requires:Split " "
		end
		if (not istable(data.requires)) then
			return false, "data.requires invalid format"
		end

		for _, feature in ipairs(data.requires) do
			if (not ttt.hud.features[feature]) then
				print("[TTTRW HUD]: Skipping element because feature missing: " .. feature)
				return
			end
		end
	end

	print("[TTTRW HUD]: Creating element " .. tostring(data.name or data.element))

	if (parent and ttt.hud.elements[data.element].Inputs.GetCustomizeParent) then
		parent = ttt.hud.elements[data.element].Inputs.GetCustomizeParent(parent)
	end


	local ele = vgui.Create("tttrw_hud_" .. data.element, parent)
	if (not parent and IsValid(ele)) then
		table.insert(ttt.hud.bases, ele)
	end
	return remove_if_error(ele, ele:SetJSON(data))
end

function ttt.hud.createfunction(name, func)
	ttt.hud.functions[name] = func
end

function ttt.hud.createinput(name, func)
	ttt.hud.inputs["$$" .. name] = func
end

local funcs = setmetatable({}, {__mode = "k"})
local global = setmetatable({
	pairs = pairs,
	ipairs = ipairs,
	tonumber = tonumber,
	tostring = tostring,
	table = {
		concat = table.concat,
		insert = insert,
	},
	pack = pack,
	unpack = unpack,
	string = {
		len = string.len,
	},
	ColorAlpha = ColorAlpha,
	Color = Color,
}, {
	__index = function(self, k)
		if (isstring(k)) then
			local input = ttt.hud.inputs["$$" .. k]
			if (input) then
				return input()
			end
		end
	end
})

local function runlua(lua)
	local func = funcs[lua]
	if (not func) then
		func = CompileString("return " .. lua, "=hud_func", false)
		if (not isfunction(func)) then
			func = CompileString(lua, "=hud_func", false)
		end

		if (not isfunction(func)) then
			funcs[lua] = false
			return
		end

		setfenv(func, global)
		funcs[lua] = func
	end

	if (func) then
		return func()
	end
end


function ttt.hud.getvalue(data)
	if (IsColor(data)) then
		return data
	elseif (istable(data)) then
		if (data.lua) then
			return runlua(data.lua)
		end

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

		local created = {}
		local couldBeColor = true
		for key, value in pairs(data) do
			created[key] = ttt.hud.getvalue(value)
			if (not isnumber(key) or not isnumber(created[key])) then
				couldBeColor = false
			end
		end

		if ((#data == 3 or #data == 4) and couldBeColor) then
			local col = Color(created[1], created[2], created[3], created[4] or 255)
			col[1], col[2], col[3], col[4] = created[1], created[2], created[3], created[4]
			return col
		end
	elseif (isstring(data)) then
		if (data:StartWith "$$") then
			local vardata = ttt.hud.current and ttt.hud.current.variables and ttt.hud.current.variables[data]

			if (vardata) then
				return ttt.hud.getvalue(vardata)
			end

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

ttt.hud.createinput("spectatingname", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:Nick()
end)

ttt.hud.createinput("spectating", function()
	return LocalPlayer():GetObserverMode() ~= OBS_MODE_NONE
end)

ttt.hud.createinput("spectatingplayer", function()
	return IsValid(ttt.GetHUDTarget())
end)

ttt.hud.createinput("guncolor", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(255, 255, 255)
	end
	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep) or not wep.GetPrintNameColor) then
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

ttt.hud.createinput("gunammo_max", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	local wep = targ:GetActiveWeapon()
	if (not IsValid(wep)) then
		return 0
	end

	return wep:GetMaxClip1() == -1 and 0 or wep:GetMaxClip1()
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

ttt.hud.createinput("healthfloat", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:Health() + targ:GetHealthFloat()
end)

ttt.hud.createinput("maxhealth", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:GetMaxHealth()
end)

ttt.hud.createinput("rolecolor", function()
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_PREPARING) then
		return ttt.roles.Spectator.Color
	end

	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return Color(0, 0, 0)
	end

	return targ:GetRoleData().Color
end)

ttt.hud.createinput("credits", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:GetCredits()
end)

ttt.hud.createinput("kills", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 0
	end

	return targ:GetKills()
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
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_PREPARING) then
		return "Preparing"
	end

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
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_PREPARING) then
		return ""
	end

	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:GetRoleTeamData().Name
end)

ttt.hud.createinput("roleicon", function()
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_PREPARING) then
		return ttt.roles.Spectator.DeathIcon
	end

	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return ""
	end

	return targ:GetRoleData().DeathIcon or ""
end)

ttt.hud.createinput("roundstate", function()
	return ttt.Enums.RoundState[ttt.GetRoundState()]
end)

local function timeleft(timeleft)
	if (timeleft <= 0) then
		return "0"
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
end

ttt.hud.createinput("timeleft", function()
	return timeleft(ttt.GetVisibleRoundEndTime() - CurTime())
end)

ttt.hud.createinput("is_evil", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return false
	end

	return targ:GetRoleData().Evil
end)

ttt.hud.createinput("evil_timeleft", function()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ) or not targ:GetRoleData().Evil) then
		return "0"
	end

	return timeleft(ttt.GetRealRoundEndTime() - CurTime())
end)

ttt.hud.createinput("is_overtime", function()
	return CurTime() > ttt.GetVisibleRoundEndTime()
end)

ttt.hud.createinput("overtime", function()
	local visibleTimeLeft = ttt.GetVisibleRoundEndTime() - CurTime()
	local defaultTime = timeleft(visibleTimeLeft)
	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
		return defaultTime
	end

	local targ = ttt.GetHUDTarget()
	local realTimeLeft = ttt.GetRealRoundEndTime() - CurTime()
	
	local isEvil = not LocalPlayer():Alive()
		or IsValid(targ)
		and targ:GetRoleData().Evil

	if (not isEvil and visibleTimeLeft <= 0) then
		return "Overtime"
	end

	if (visibleTimeLeft <= 0) then
		return "(" .. timeleft(realTimeLeft) .. ")"
	end

	return defaultTime
end)


local INPUTS = {}

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
	self.EditableChildren = self.EditableChildren or {}
	for _, childdata in ipairs(data) do
		local ele, err = ttt.hud.create(childdata, self)
		if (not ele) then
			return err
		end
		table.insert(self.EditableChildren, ele)
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
	center = function(x, y, w, h)
		return ScrW() / 2 + x - w / 2, y, w, h
	end,
	left = function(x, y, w, h)
		return x, y, w, h
	end,
	top = function(x, y, w, h)
		return x, y, w, h
	end,
	bottom = function(x, y, w, h)
		return x, ScrH() - y - h, w, h
	end,
	middle = function(x, y, w, h)
		return x, ScrH() / 2 + y, w, h
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

	local w, h = self:GetSize()

	if (istable(dat.size)) then
		w, h = ttt.hud.getvalue(dat.size[1]), ttt.hud.getvalue(dat.size[2])
		self:SetSize(w, h)
	end

	if (dat.from) then
		if (isstring(dat.from)) then
			dat.from = dat.from:Split " "
		end

		for i = #dat.from, 1, -1 do
			if (dat.from[i] == "middle" or dat.from[i] == "center") then
				local what = dat.from[i]
				table.remove(dat.from, i)
				table.insert(dat.from, what)
				-- always at end
			end
		end

		for _, from in ipairs(dat.from) do
			if (not transform[from]) then
				return "invalid transform: " .. from
			end

			x, y, w, h = transform[from](x, y, w, h)
		end
	end

	self:SetPos(x, y)
end

function INPUTS:SetFrameupdate(arr)
	if (not istable(arr)) then
		return "invalid frameupdate input"
	end

	hook.Add("PreRender", self, function()
		local toremove = {}
		for i, key in ipairs(arr) do
			local val = self.TTTRWHUDElement[key]
			if (val == nil) then
				table.insert(toremove, i)
				continue
			end

			local err = self:Update(key)
			if (err) then
				warn("%s: %s", self, err)
			end
		end

		for i = #toremove, 1, -1 do
			table.remove(arr, toremove[i])
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
		elseif (what.what == "contents") then
			self:SizeToContentsX(what.width)
			self:SizeToContentsY(what.height)
		end
	end
end

function INPUTS:SetCenter(b)
	self:Center()
end

function INPUTS:SetRequires(req)
	-- workaround
end

function INPUTS:SetVisible(b)
	self:SetVisible(b)
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
	self:SetFont(ttt.hud.createfont(font))
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

local notAllowedToResizeDock = {
	fill = true,
	top = true,
	bottom = true,
}

function INPUTS:SetText(text)
	self:SetText(ttt.hud.getvalue(text))
	-- probably will need to add more stuff here:
	if (not notAllowedToResizeDock[Get(self, "dock")]) then
		self:SizeToContentsX()
	end
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

local PANEL = {}

PANEL.PolygonDefault = {
	{x = 0, y = 0},
	{x = 1, y = 0},
	{x = 1, y = 1},
	{x = 0, y = 1},
}

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:GetColor()
	return self.Color or white_text
end

function PANEL:SetPolygon(polygon)
	self.Polygon = polygon
	self:ResizePolygon(self:GetSize())
end

function PANEL:GetPolygon()
	return self.Polygon or self.PolygonDefault
end

function PANEL:GetSizedPolygon()
	if (not self.SizedPolygon) then
		self:ResizePolygon(self:GetSize())
	end

	return self.SizedPolygon
end

function PANEL:PerformLayout(w, h)
	self:ResizePolygon(w, h)  
end

function PANEL:ResizePolygon(w, h)
	local polygon = self:GetPolygon()
	local newPolygon = {}
	for i = 1, #polygon do
		newPolygon[i] = {x = polygon[i].x * w, y = polygon[i].y * h}
	end

	self.SizedPolygon = newPolygon
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetColor())
	draw.NoTexture()
	render.PushFilterMin(TEXFILTER.ANISOTROPIC)
	render.PushFilterMag(TEXFILTER.ANISOTROPIC)
	surface.DrawPoly(self.SizedPolygon)
	render.PopFilterMag()
	render.PopFilterMin()
end

vgui.Register("tttrw_polygon", PANEL, "EditablePanel")

local INPUTS = {}

function INPUTS:SetColor(col)
	self:SetColor(ttt.hud.getvalue(col))
end

function INPUTS:SetPolygon(polygon)
	self:SetPolygon(ttt.hud.getvalue(polygon))
end

ttt.hud.registerelement("polygon", INPUTS, "base", "ve_polygon")