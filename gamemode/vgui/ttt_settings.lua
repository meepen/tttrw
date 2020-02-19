
local self = {}
local Setting_mt = {
	__index = self,
	__call = function(self, v)
		for k,v in pairs(v) do
			self[k] = v
		end
	end
}

local function AccessorFunc(self, name, fnname)
	fnname = fnname or name
	self["Get" .. fnname] = function(self)
		return self[name]
	end

	self["Set" .. fnname] = function(self, v)
		self[name] = v
		return self
	end
end

AccessorFunc(self, "ConVar")

local function Setting(name)
	local t = Settings[name] or setmetatable({
		Name = name
	}, Settings_mt)

	return t
end

local bg_color = CreateMaterial("ttt_settings_color" .. math.random(0, 0x8000), "UnlitGeneric", {
	["$basetexture"] = "color/white",
	["$color"] = "{ 13 12 13 }",
	["$alpha"] = 0.92
})

local ttt_body_normal = Color(51, 51, 52)

surface.CreateFont("ttt_settings_tab_font", {
	font = 'Lato',
	size = math.max(24, ScrH() / 80),
	weight = 400
})

surface.CreateFont("ttt_settings_settings_text_font", {
	font = 'Roboto',
	size = math.max(16, ScrH() / 80),
	weight = 0
})

surface.CreateFont("ttt_settings_header_font", {
	font = 'Lato',
	size = math.max(24, ScrH() / 80),
	weight = 200
})

local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
	self.Button.OnChange = function(_, val)
		self:OnChange(val)
	end

	self.Button:Dock(LEFT)
	self.Button:DockMargin(0, 0, Padding, 0)

	self.Label:SetMouseInputEnabled(true)
	self.Label.DoClick = function()
		self:Toggle()
	end
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(4)
end

function PANEL:PerformLayout(w, h)
	self.Button:SetWide(h)
end

vgui.Register("ttt_checkbox_label", PANEL, "DCheckBoxLabel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(6)
	self:SetColor(Color(78, 76, 80))
	self.Label = self:Add "DLabel"
	self.Label:SetFont "ttt_settings_tab_font"
	surface.SetFont(self.Label:GetFont())
	local _, h = surface.GetTextSize "A"

	self:SetTall(h + Padding)

	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
end

function PANEL:SetText(t)
	self.Label:SetText(t)
end

vgui.Register("ttt_settings_header_stuff", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self.Index = 1
	self:Dock(TOP)
end

function PANEL:SetText(t)
	self.Header:SetText(t)
end

function PANEL:AddCheckBox(desc, convar)
	local lbl = self:Add "ttt_checkbox_label"
	lbl:SetZPos(self.Index)
	self.Index = self.Index + 1
	lbl:DockMargin(0, Padding, 0, 0)

	lbl:SetConVar(convar)
	lbl:SetText(desc)
	lbl:SetFont "ttt_settings_settings_text_font"
	lbl:SetValue(GetConVar(convar):GetBool())
	lbl:Dock(TOP)
	surface.SetFont(lbl.Label:GetFont())
	local _, h = surface.GetTextSize "A"
	lbl:SetTall(h + Padding / 2)

	self.Last = lbl
end

function PANEL:AddLabel(text)
	surface.SetFont "ttt_settings_settings_text_font"
	local _, h = surface.GetTextSize "A"

	local lbl = self:Add "DLabel"
	lbl:SetZPos(self.Index)
	self.Index = self.Index + 1
	if (IsValid(self.Last)) then
		lbl:DockMargin(0, Padding, 0, 0)
	end

	lbl:SetText(text)
	lbl:SetTextColor(white_text)
	lbl:SetFont "ttt_settings_settings_text_font"
	lbl:Dock(TOP)
	lbl:SetTall(h + Padding / 2)
	lbl:SetContentAlignment(5)

	self.Last = lbl

	return h
end

function PANEL:AddLabelButton(text)
	local btn = self:Add "ttt_curved_panel_shadow_button"
	btn.Inner = btn:Add "ttt_curved_panel_outline"
	btn.Inner:SetMouseInputEnabled(false)
	btn.Inner:Dock(FILL)

	btn.InnerShadow = btn.Inner:Add "ttt_curved_panel_shadow"
	btn.InnerShadow:Dock(FILL)

	btn.Fill = btn.InnerShadow:Add "ttt_curved_panel"
	btn.Fill:Dock(FILL)

	btn.Label = btn.Fill:Add "DLabel"
	btn.Label:SetContentAlignment(5)
	btn.Label:SetFont "tttrw_tab_selector"
	btn.Label:Dock(FILL)
	btn.Label:SetText(text)
	btn.Label:SetTextColor(white_text)


	btn.SetRealColor = btn.SetColor
	function btn:SetColor(col)
		self.Fill:SetColor(col)
	end

	btn:SetColor(solid_color)

	btn.InnerShadow:DockPadding(2, 2, 2, 2)

	btn.InnerShadow:SetColor(outline)
	btn.Inner:SetColor(outline)
	btn:SetRealColor(outline)
	btn.InnerShadow:SetCurve(4)
	btn.Inner:SetCurve(4)
	btn:SetCurve(4)
	btn.Fill:SetCurve(2)

	btn:Dock(TOP)
	btn:DockMargin(0, 0, 0, 12)
	surface.SetFont "ttt_settings_settings_text_font"
	local _, h = surface.GetTextSize "A"
	btn:SetTall(h + Padding / 2)

	btn.Label:SetText(text)
	btn:SetZPos(self.Index)
	btn:DockMargin(0, 0, 0, Padding)

	self.Last = btn
	self.Index = self.Index + 1

	return btn
end

function PANEL:AddTextEntry(text, convar, v, enabled)
	local h = self:AddLabel(text)

	local text = self:Add "DTextEntry"
	text:SetZPos(self.Index)
	self.Index = self.Index + 1
	text:DockMargin(0, Padding / 5, 0, 0)

	text:SetFont "ttt_settings_settings_text_font"
	text:Dock(TOP)
	text:SetTall(h + Padding / 2)
	if (isstring(convar)) then
		text:SetConVar(convar)
		text:SetText(GetConVar(convar):GetString())
	elseif (v) then
		text:SetText(v)
	else
		text:SetText ""
	end
	text:SetDisabled(not convar)

	self.Last = text

	return text
end

function PANEL:AddSlider(text, convar)
	self:AddLabel(text)

	local lbl = self.Last

	local p = self:Add "DSlider"
	p:SetSkin "tttrw"
	p:Dock(TOP)
	p:SetZPos(self.Index)
	local cv = GetConVar(convar)
	lbl:SetText(text .. string.format(" (%.2f)", cv:GetFloat()))

	local old = p.OnCursorMoved

	function p:OnCursorMoved(x, y)
		old(self, x, y)

		cv:SetFloat(self:GetSlideX() * (cv:GetMax() - cv:GetMin()) + cv:GetMin())

		lbl:SetText(text .. string.format(" (%.2f)", cv:GetFloat()))
	end

	p:SetSlideX((cv:GetFloat() - cv:GetMin()) / (cv:GetMax() - cv:GetMin()))

	self.Index = self.Index + 1

	self.Last = p
end

function PANEL:AddBinder(text, callback)
	self:AddLabel(text)
	local btn = self:AddLabelButton(text)
	btn:DockMargin(0, 0, 0, 0)
	function btn:DoClick()
		self:SetText("Press a key")
		input.StartKeyTrapping()
		self.Trapping = true
	end

	function btn:DoRightClick()
		self:SetText("Not bound")
		self.SelectedCode = 0

		callback(nil)
	end

	function btn:Think()
		if (input.IsKeyTrapping() and self.Trapping) then
			local code = input.CheckKeyTrapping()

			if (code) then
				if (code == KEY_ESCAPE) then
					if (self.SelectedCode) then
						local key = input.GetKeyName(self.SelectedCode)
						self:SetText("Bound to: " .. string.upper(key))
					else
						self:SetText("Not bound")
					end
				else
					self.SelectedCode = code
					local key = input.GetKeyName(code)
					self:SetText("Bound to: " .. string.upper(key))
					callback(code)
				end

				self.Trapping = false
			end
		end
	end

	return btn
end

function PANEL:SizeToContents()
	self:SetTall(select(2, self.Last:GetPos()) + self.Last:GetTall())
end

vgui.Register("ttt_settings_category", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	local crosshair = self:Add "EditablePanel"
	crosshair:SetPos(25,0)
	crosshair:SetSize(200,475)
	function crosshair:Paint(w, h)
		ttt.DefaultCrosshair(w / 2, h / 2)
	end

	local col = self:Add "DColorMixer"
	col:SetPos(crosshair:GetWide() - 400 + 450,50)
	col:SetSize(300,150)
	col:SetPalette(true)
	col:SetWangs(true)
	col:SetAlphaBar(false)
	col:SetColor(Color(GetConVar("tttrw_crosshair_color_r"):GetInt(),GetConVar("tttrw_crosshair_color_g"):GetInt(),GetConVar("tttrw_crosshair_color_b"):GetInt()))
	col:SetConVarR("tttrw_crosshair_color_r")
	col:SetConVarG("tttrw_crosshair_color_g")
	col:SetConVarB("tttrw_crosshair_color_b")

	local thick = self:Add "DNumSlider"
	thick:SetPos(crosshair:GetWide() - 400 + 450,200)
	thick:SetSize(300,50)
	thick:SetText("Thickness")
	thick:SetMin(0)
	thick:SetMax(30)
	thick:SetDecimals(0)
	thick:SetConVar("tttrw_crosshair_thickness")

	local len = self:Add "DNumSlider"
	len:SetPos(crosshair:GetWide() - 400 + 450,240)
	len:SetSize(300,50)
	len:SetText("Length")
	len:SetMin(0)
	len:SetMax(100)
	len:SetDecimals(0)
	len:SetConVar("tttrw_crosshair_length")

	local gap = self:Add "DNumSlider"
	gap:SetPos(crosshair:GetWide() - 400 + 450,280)
	gap:SetSize(300,50)
	gap:SetText("Gap")
	gap:SetMin(0)
	gap:SetMax(50)
	gap:SetDecimals(0)
	gap:SetConVar("tttrw_crosshair_gap")

	local op = self:Add "DNumSlider"
	op:SetPos(crosshair:GetWide() - 400 + 450,320)
	op:SetSize(300,50)
	op:SetText("Opacity")
	op:SetMin(0)
	op:SetMax(255)
	op:SetDecimals(0)
	op:SetConVar("tttrw_crosshair_opacity")

	local outop = self:Add "DNumSlider"
	outop:SetPos(crosshair:GetWide() - 400 + 450,360)
	outop:SetSize(300,50)
	outop:SetText("Outline Opacity")
	outop:SetMin(0)
	outop:SetMax(255)
	outop:SetDecimals(0)
	outop:SetConVar("tttrw_crosshair_outline_opacity")

	local dot = self:Add "DNumSlider"
	dot:SetPos(crosshair:GetWide() - 400 + 450,400)
	dot:SetSize(300,50)
	dot:SetText("Dot Size")
	dot:SetMin(0)
	dot:SetMax(20)
	dot:SetDecimals(0)
	dot:SetConVar("tttrw_crosshair_dot_size")

	local dotop = self:Add "DNumSlider"
	dotop:SetPos(crosshair:GetWide() - 400 + 450,440)
	dotop:SetSize(300,50)
	dotop:SetText("Dot Opacity")
	dotop:SetMin(0)
	dotop:SetMax(255)
	dotop:SetDecimals(0)
	dotop:SetConVar("tttrw_crosshair_dot_opacity")

	local spreadmult = self:Add "DNumSlider"
	spreadmult:SetPos(crosshair:GetWide() - 400 + 450,480)
	spreadmult:SetSize(300,50)
	spreadmult:SetText("Spread Multiplier")
	spreadmult:SetMin(0)
	spreadmult:SetMax(2048)
	spreadmult:SetDecimals(0)
	spreadmult:SetConVar("tttrw_crosshair_spread_multiplier")

	local reset = self:Add "DButton"
	reset:SetPos(75,465)
	reset:SetSize(100,50)
	reset:SetText("Reset")
	function reset:DoClick()
		col:SetColor(Color(232,80,94))
		thick:SetValue(2)
		len:SetValue(7)
		gap:SetValue(3)
		op:SetValue(255)
		outop:SetValue(255)
		dot:SetValue(0)
		dotop:SetValue(255)
	end

	self:SetSize(800, 540)
end

vgui.Register("tttrw_crosshair_customize", PANEL, "EditablePanel")

local RadioBinds = {}

do
	local f = file.Open("tttrw_radio_binds.json", "rb", "DATA")

	if (f) then
		RadioBinds = util.JSONToTable(f:Read(f:Size()))

		f:Close()
	else
		printf("Couldn't open file: tttrw_radio_binds.json")
	end
end

local function RegisterRadioBind(key, command)
	RadioBinds[command] = key

	local f = file.Open("tttrw_radio_binds.json", "wb", "DATA")

	if (not f) then
		printf("Couldn't open file: tttrw_radio_binds.json")
		return
	end

	f:Write(util.TableToJSON(RadioBinds))

	f:Close()
end

hook.Add("PlayerButtonDown", "tttrw_radio_binds", function(ply, key)
	if (IsFirstTimePredicted()) then
		for k, v in pairs(RadioBinds) do
			if (v == key) then
				RunConsoleCommand("_ttt_radio_send", k)
			end
		end
	end
end)

function GM:ShowHelp()
	if (not IsValid(ttt.settings)) then
		ttt.settings = vgui.Create "tttrw_base"
		local gameplay = vgui.Create "ttt_settings_category"

		gameplay:AddCheckBox("Spectator Mode", "tttrw_afk")
		gameplay:AddCheckBox("Aim Down Sights Toggle", "tttrw_toggle_ads")
		gameplay:AddCheckBox("Outline players roles", "tttrw_outline_roles")
		gameplay:AddCheckBox("Automatically Bunny hop", "ttt_bhop_cl")
		gameplay:AddCheckBox("Lowered Ironsights", "ttt_ironsights_lowered")
		gameplay:AddCheckBox("Enable annoying HL2 crosshair", "hud_quickinfo")
		gameplay:AddCheckBox("Enable Multicore Rendering (gives fps)", "tttrw_mcore")
		gameplay:InvalidateLayout(true)
		gameplay:SizeToContents()
		ttt.settings:AddTab("Gameplay", gameplay)

		local sound = vgui.Create "ttt_settings_category"
		sound:AddTextEntry("Where to put sounds (create if not exist)", nil, util.RelativePathToFull ".":sub(1, -2) .. "sound")
		sound:AddTextEntry("Hitmarker", "tttrw_hitmarker_sound")
		sound:AddTextEntry("Hitmarker (Headshot)", "tttrw_hitmarker_sound_hs")
		sound:AddTextEntry("DNA Beep", "tttrw_dna_beep_sound")
		sound:InvalidateLayout(true)
		sound:SizeToContents()
		ttt.settings:AddTab("Sound", sound)

		ttt.settings:AddTab("Crosshair", vgui.Create "tttrw_crosshair_customize")

		local radio = vgui.Create "ttt_settings_category"
		for k, v in pairs(ttt.QuickChat) do
			local btn = radio:AddBinder(v, function(key)
				RegisterRadioBind(key, k)
			end)

			if (RadioBinds[k] and input.GetKeyName(RadioBinds[k])) then
				btn:SetText("Bound to: " .. string.upper(input.GetKeyName(RadioBinds[k])))
			else
				btn:SetText("Not bound")
			end
		end

		radio:InvalidateLayout(true)
		radio:SizeToContents()
		ttt.settings:AddTab("Binds", radio)

		ttt.settings:SetSize(640, 400)
		ttt.settings:Center()
		ttt.settings:MakePopup()

		hook.Run "TTTPopulateSettingsMenu"
	end
end