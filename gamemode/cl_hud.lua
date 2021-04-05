DEFINE_BASECLASS "gamemode_base"

local DrawTextShadowed = hud.DrawTextShadowed

local health_full = Color(58, 180, 80)
local health_ok = Color(240, 255, 0)
local health_dead = Color(255, 51, 0)

function ColorLerp(frac, ...)
	local amt = select("#", ...)

	if (frac <= 0) then
		return (...)
	elseif (frac >= 1) then
		return select(amt, ...)
	end

	local cur_index = math.max(0, math.min(amt, math.floor(frac * (amt - 1)) + 1))
	local from, to = select(cur_index, ...)

	local frac_between = (frac / (1 / (amt - 1))) % 1

	local dr, dg, db = to.r - from.r, to.g - from.g, to.b - from.b

	return Color(from.r + dr * frac_between, from.g + dg * frac_between, from.b + db * frac_between)
end

function ttt.GetHUDTarget()
	local ply = LocalPlayer()
	if (ply.GetObserverMode and (ply:GetObserverMode() == OBS_MODE_IN_EYE or ply:GetObserverMode() == OBS_MODE_CHASE) and ply:GetObserverTarget():IsPlayer()) then
		return ply:GetObserverTarget()
	end
	return ply
end

local LastTarget, LastTime

local unided_color = Color(163, 148, 47)

surface.CreateFont("TTTRWTargetID", {
	font = "Roboto",
	extended = true,
	size = 20,
	shadow = true,
})

function GM:HUDDrawTargetID()
	local ent = ttt.GetHUDTarget()
	local ply = LocalPlayer()

	if (not IsValid(ent) or (ply.GetObserverTarget and ply:GetObserverTarget() == OBS_MODE_CHASE)) then return end

	local tr = ent:GetEyeTrace(MASK_SHOT)
	ent = tr.Entity
	if (not IsValid(ent)) then return end

	local text = "n/a"
	local extra, extra_col = nil, white_text
	local color = white_text

	local disguised = false

	if (ent:IsPlayer()) then
		if (ent.HasDisguiser and ent:HasDisguiser()) then
			disguised = true
		end

		text = ent:Nick()
	elseif (ent:GetNW2Bool("IsPlayerBody", false)) then
		local state = ent.HiddenState
		if (not IsValid(state)) then
			text = "Unidentified Body"
			color = unided_color
		else
			local own = ent.HiddenState
			text = own:GetNick() .. "'s body"
			color = ttt.roles[ent.HiddenState:GetRole()].Color
			if (not ent.HiddenState:GetIdentified()) then
				extra = "(unidentified)"
				extra_col = unided_color
			end
		end
	else
		return
	end

	if (LastTarget ~= ent or LastTime and LastTime < CurTime() - 1) then
		LastTarget = ent
		LastTime = CurTime()
		net.Start "ttt_player_target"
			net.WriteEntity(ent)
		net.SendToServer()
		LocalPlayer():SetTarget(ent)
		timer.Create("EliminateTarget", 3, 1, function()
			LocalPlayer():SetTarget(nil)
		end)
	end

	local disguisemsg = ""

	if (disguised) then
		if (IsValid(ent.HiddenState) and not ent.HiddenState:IsDormant()) then
			disguisemsg = " (Disguised)"
		else
			return
		end
	end

	surface.SetFont "TTTRWTargetID"
	surface.SetTextColor(color_black)

	local x, y = ScrW() / 2, ScrH() / 2

	y = y + math.max(50, ScrH() / 20)

	local tw, th = surface.GetTextSize(text)

	hud.DrawTextOutlined(text, color, color_black, x - tw / 2, y, 1)

	if (extra) then
		hud.DrawTextOutlined(extra, extra_col, color_black, x - surface.GetTextSize(extra) / 2, y + th + 2, 1)
	end


	if (IsValid(ent) and ent:IsPlayer()) then

		local state = ent.HiddenState

		if (IsValid(state) and not state:IsDormant()) then
			y = y + th + 4
			local role = ent:GetRoleData()
			local col = role.Color
			local txt = role.Name .. disguisemsg

			tw, th = surface.GetTextSize(txt)

			hud.DrawTextOutlined(txt, col, color_black, x - tw / 2, y, 1)
		end

		local health, maxhealth = ent:Health(), ent:GetMaxHealth()

		local scrw = ScrW()

		local hppct = health / maxhealth
		local wid = math.max(40, math.min(scrw / 45, 100))
		local hpw = math.ceil(wid * hppct)
		y = y + th + 4

		local r, g, b = ColorLerp(hppct, health_dead, health_ok, health_full)
		local a = 230
		th = math.ceil(th / 2)
		surface.SetDrawColor(r, g, b, a)
		surface.DrawRect(x - wid / 2, y, hpw, th)
		surface.SetDrawColor(0, 0, 0, a)
		surface.DrawRect(x - wid / 2 + hpw, y, wid - hpw, th)

		surface.SetDrawColor(12, 13, 12, 255)
		surface.DrawOutlinedRect(x - wid / 2 - 1, y - 1, wid + 2, th + 2)

		local status = ttt.GetPlayerStatus(ent)
		if (status ~= ttt.STATUS_DEFAULT) then
			hud.DrawTextOutlined(ttt.Status[status].text, ttt.Status[status].color, color_black, x - surface.GetTextSize(ttt.Status[status].text) / 2, y + th + 4, 1)
		end
	end
end

function GM:HUDPaintBackground()
	hook.Run "TTTDrawDamagePosition"
end

function GM:HUDPaint()
	hook.Run "HUDDrawTargetID"
	hook.Run "TTTDrawHitmarkers"
	if (not LocalPlayer():Alive() or ttt.Enums.RoundState[ttt.GetRoundState()] == "Ended") then
		hook.Run "TTTRWDrawSpectatorHUD"
	end

	local targ = ttt.GetHUDTarget()
	local ply = LocalPlayer()

	if (IsValid(targ) and targ ~= LocalPlayer() and not (ply.GetObserverMode and ply:GetObserverMode() == OBS_MODE_CHASE)) then
		-- https://github.com/Facepunch/garrysmod-issues/issues/3936
		local wep = targ:GetActiveWeapon()
		if (IsValid(wep) and wep.DoDrawCrosshair) then
			wep:DoDrawCrosshair(ScrW() / 2, ScrH() / 2)
		end
	end
end

function GM:PlayerPostThink()
	if (not IsFirstTimePredicted()) then
		return
	end

	local targ = ttt.GetHUDTarget()

	if (IsValid(targ) and targ ~= LocalPlayer()) then
		local wep = targ:GetActiveWeapon()
		if (IsValid(wep) and wep.CalcAllUnpredicted) then
			wep:CalcAllUnpredicted()
		end
	end
end


local hide = {
	CHudHealth = true,
	CHudDamageIndicator = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudBattery = true
}

function GM:HUDShouldDraw(name)
	if (hide[name]) then
		return false
	end
	
	return true
end

local default = [=[{
	"variables": {
		"weaponselect.number": {
			"weight": 500.0,
			"font": "Roboto",
			"size": 16.0
		},
		"$$healthcolor": "#fff",
		"weaponselect.weapon": {
			"weight": 300.0,
			"font": "Roboto",
			"size": 18.0
		}
	},
	"elements": [
		{
			"color": [
				255.0,
				0.0,
				111.0,
				0.0
			],
			"children": [
				{
					"positioning": {
						"size": [
							6.0,
							0.0
						]
					},
					"frameupdate": [
						"color"
					],
					"margin": [
						0.0,
						0.0,
						6.0,
						0.0
					],
					"color": {
						"lua": "ColorAlpha(rolecolor, 64)"
					},
					"children": [
						{
							"color": "$$rolecolor",
							"frameupdate": [
								"color"
							],
							"element": "curve",
							"name": "rolecolor_bar",
							"dock": "fill"
						}
					],
					"element": "curve_outline",
					"name": "rolecolor_bar_outline",
					"dock": "left"
				},
				{
					"positioning": {
						"size": [
							84.0,
							0.0
						]
					},
					"margin": [
						16.0,
						0.0,
						0.0,
						0.0
					],
					"children": [
						{
							"element": "label",
							"font": {
								"weight": 500.0,
								"font": "Roboto",
								"size": 28.0
							},
							"dock": "fill",
							"contentalignment": 1.0,
							"frameupdate": [
								"text"
							],
							"text": "$$health",
							"margin": [
								0.0,
								0.0,
								0.0,
								25.0
							],
							"rendersystem": "shadow",
							"name": "healthlabel"
						}
					],
					"element": "base",
					"name": "healthcontainer",
					"dock": "right"
				},
				{
					"positioning": {
						"size": [
							0.0,
							18.0
						]
					},
					"margin": [
						0.0,
						14.0,
						0.0,
						1.0
					],
					"children": [
						{
							"dock": "left",
							"image": "$$roleicon",
							"frameupdate": [
								"image"
							],
							"element": "image",
							"name": "roleimage",
							"positioning": {
								"size": [
									18.0,
									18.0
								]
							}
						},
						{
							"children": [
								{
									"color": "$$teamcolor",
									"element": "label",
									"font": {
										"weight": 500.0,
										"font": "Roboto",
										"size": 18.0
									},
									"dock": "right",
									"contentalignment": 3.0,
									"frameupdate": [
										"text",
										"color"
									],
									"rendersystem": "shadow",
									"name": "teamlabel",
									"text": "$$teamname"
								}
							],
							"element": "label",
							"font": {
								"weight": 500.0,
								"font": "Roboto",
								"size": 20.0
							},
							"text": "$$rolename",
							"contentalignment": 4.0,
							"frameupdate": [
								"text"
							],
							"margin": [
								6.0,
								0.0,
								0.0,
								0.0
							],
							"name": "rolelabel",
							"rendersystem": "shadow",
							"dock": "fill"
						}
					],
					"element": "base",
					"name": "rolecontainer",
					"dock": "bottom"
				},
				{
					"dock": "bottom",
					"curve": 6.0,
					"color": "#000000",
					"children": [
						{
							"scissor": [
								0.0,
								0.0,
								{
									"lua": "1 - health / maxhealth"
								},
								0.0
							],
							"curve": "inherit",
							"color": "$$healthcolor",
							"element": "curve",
							"name": "healthbar",
							"dock": "fill"
						},
						{
							"element": "curve",
							"color": "$$rolecolor",
							"curve": "inherit",
							"frameupdate": [
								"color"
							],
							"scissor": [
								0.0,
								7.0,
								{
									"lua": "1 - armor / maxarmor"
								},
								0.0
							],
							"name": "armorbar",
							"dock": "fill"
						}
					],
					"element": "curve_outline",
					"name": "healthbaroutline",
					"positioning": {
						"size": [
							128.0,
							12.0
						]
					}
				},
				{
					"children": [
						{
							"color": "$$teamcolor",
							"element": "label",
							"font": {
								"weight": 500.0,
								"font": "Roboto",
								"size": 18.0
							},
							"dock": "right",
							"contentalignment": 3.0,
							"frameupdate": [
								"text",
								"color"
							],
							"text": "$$overtime",
							"rendersystem": "shadow",
							"name": "overtime_label"
						}
					],
					"element": "label",
					"font": {
						"weight": 300.0,
						"font": "Roboto",
						"size": 24.0
					},
					"margin": [
						0.0,
						1.0,
						0.0,
						6.0
					],
					"contentalignment": 4.0,
					"frameupdate": [
						"text"
					],
					"dock": "fill",
					"rendersystem": "shadow",
					"name": "roundstate_label",
					"text": {
						"lua": "roundstate .. (timeleft ~= '' and ': ' .. timeleft or '')"
					}
				}
			],
			"element": "curve",
			"name": "bottomleft_area",
			"positioning": {
				"offset": [
					26.0,
					50.0
				],
				"size": [
					330.0,
					92.0
				],
				"from": [
					"bottom"
				]
			}
		},
		{
			"children": [
				{
					"color": {
						"lua": "ColorAlpha(guncolor, 96)"
					},
					"children": [
						{
							"element": "label",
							"font": {
								"weight": 300.0,
								"font": "Roboto",
								"size": 22.0
							},
							"text": "$$gunname",
							"contentalignment": 6.0,
							"frameupdate": [
								"text"
							],
							"margin": [
								0.0,
								0.0,
								12.0,
								0.0
							],
							"name": "weapon_name",
							"dock": "right"
						}
					],
					"element": "image",
					"dock": "bottom",
					"image": "gui/gradient.png",
					"frameupdate": [
						"color"
					],
					"positioning": {
						"size": [
							0.0,
							28.0
						]
					},
					"margin": [
						34.0,
						4.0,
						0.0,
						0.0
					],
					"name": "weapon_name_gradient",
					"reverse": true
				},
				{
					"dock": "bottom",
					"margin": [
						0.0,
						4.0,
						0.0,
						0.0
					],
					"color": "#888",
					"element": "curve",
					"name": "gundivider",
					"positioning": {
						"size": [
							0.0,
							1.0
						]
					}
				},
				{
					"children": [
						{
							"padding": [
								6.0,
								0.0,
								6.0,
								0.0
							],
							"curve": 4.0,
							"color": [
								20.0,
								20.0,
								20.0,
								208.0
							],
							"children": [
								{
									"element": "label",
									"font": {
										"weight": 300.0,
										"font": "Roboto",
										"size": 24.0
									},
									"text": "$$gunreserves",
									"contentalignment": 5.0,
									"sizeto": "contents",
									"frameupdate": [
										"text",
										"sizeto",
										"center"
									],
									"rendersystem": "shadow",
									"name": "reserve_label"
								}
							],
							"element": "curve",
							"margin": [
								0.0,
								18.0,
								0.0,
								4.0
							],
							"sizeto": {
								"what": "children",
								"width": true
							},
							"frameupdate": [
								"sizeto"
							],
							"name": "reserve_container",
							"dock": "right"
						},
						{
							"element": "label",
							"font": {
								"weight": 300.0,
								"font": "Roboto",
								"size": 48.0
							},
							"margin": [
								0.0,
								0.0,
								8.0,
								0.0
							],
							"contentalignment": 3.0,
							"frameupdate": [
								"text"
							],
							"dock": "right",
							"name": "current_ammo",
							"text": "$$gunammo"
						}
					],
					"element": "base",
					"name": "ammocontainer",
					"dock": "fill"
				}
			],
			"element": "base",
			"name": "gunammo",
			"positioning": {
				"offset": [
					26.0,
					50.0
				],
				"size": [
					290.0,
					100.0
				],
				"from": [
					"bottom",
					"right"
				]
			}
		},
		{
			"contentalignment": 6.0,
			"element": "weaponselect",
			"name": "weapon_select",
			"positioning": {
				"size": [
					0.0,
					0.0
				],
				"from": [
					"middle",
					"right"
				]
			}
		}
	]
}]=]

file.CreateDir "tttrw"
local function init_hud()
	local json
	
	local s, e = pcall(function()
		json = util.JSONToTable(file.Read("tttrw/hud.json", "DATA") or default)
	end)
	
	if (not s or not json) then
		warn("%s", e or "json ded")
		return
	end
	ttt.hud.init(json)

	if (IsValid(ttt.hudeditor)) then
		ttt.hudeditor:Remove()
		timer.Create("tttrw_hud_edit", 0, 1, function()
			RunConsoleCommand "tttrw_hud_edit"
		end)
	end
end

hook.Add("HUDPaint", "tttrw_hud_init", function()
	init_hud()
	hook.Remove("HUDPaint", "tttrw_hud_init")
end)

hook.Add("OnScreenSizeChanged", "tttrw_hud_init", init_hud)

concommand.Add("tttrw_hud_init", init_hud)

local function GetHoveredPanel()
	local p = vgui.GetHoveredPanel()
	while (p) do
		if (p.TTTRWHUDElement) then
			break
		end
		p = p:GetParent()
	end

	if (not p or not p.TTTRWHUDElement) then
		return
	end
	
	return p
end

concommand.Add("tttrw_hud_edit", function()
	if (IsValid(ttt.hudeditor)) then
		ttt.hudeditor:Remove()
	else
		ttt.hudeditor = vgui.Create "tttrw_hud_editor"
		ttt.hudeditor:MakePopup()
	end
end)

local PANEL = {}

function PANEL:Init()
	self:SetSize(300, 300)

	self.Buttons = self:Add "EditablePanel"
	self.Buttons:Dock(BOTTOM)
	self.Buttons:SetTall(25)
	self.Buttons:DockMargin(0, 0, 0, 8)
	function self.Buttons:PerformLayout(w, h)
		local pad = 20
		local tw = -pad
		for _, child in ipairs(self:GetChildren()) do
			tw = tw + child:GetWide() + pad
		end

		local x = w / 2 - tw / 2
		for _, child in ipairs(self:GetChildren()) do
			child:SetPos(x, 0)
			x = x + child:GetWide() + pad
		end
	end

	function self.Buttons:AddButton(init)
		local btn = self:Add "DButton"
		btn:SetTall(self:GetTall())
		if (init) then
			init(btn)
		end

		self:InvalidateLayout(true)

		return btn
	end

	self.UpdateButton = self.Buttons:AddButton(function(btn)
		btn:SetText "Update Current"
		btn:SetDisabled(true)
		btn:SizeToContentsX(20)
	end)

	self.SaveButton = self.Buttons:AddButton(function(btn)
		btn:SetText "Save All"
		btn:SizeToContentsX(20)
	end)

	self.ReloadButton = self.Buttons:AddButton(function(btn)
		btn:SetText "Reload HUD"
		btn:SizeToContentsX(20)
	end)

	self.ResetButton = self.Buttons:AddButton(function(btn)
		btn:SetText "Reset to Default"
		btn:SizeToContentsX(20)
	end)

	function self.ResetButton.DoClick()
		Derma_Query("Completely reset HUD?", "Reset", "Yes", function()
			file.Delete "tttrw/hud.json"
			init_hud()
		end, "No", function() end)
	end

	function self.ReloadButton.DoClick()
		Derma_Query("Reload HUD and remove all current changes?", "Reload", "Yes", function()
			init_hud()
		end, "No", function() end)
	end

	function self.UpdateButton.DoClick()
		self:DoUpdate()
	end

	function self.SaveButton.DoClick()
		self:SaveAll()
	end

	self.Scroller = self:Add "DScrollPanel"
	self.Scroller:Dock(FILL)
end

local function tovalue(v)
	if (v == "") then
		return
	end

	local n = tonumber(v)
	if (n) then
		return n
	end

	if (isstring(v)) then
		local t = util.JSONToTable(v)
		if (t) then
			return t
		end
	end

	if (isstring(v)) then
		local m = v:match "^\"(.*)\"$"
		if (m) then
			return m
		end
	end
	return error("invalid value: " .. tostring(v))
end

function PANEL:SaveAll()
	local function generate_json(p)
		local t = IsValid(p) and table.Copy(p.TTTRWHUDElement) or {}
		if (p.EditableChildren) then
			t.children = {}

			for _, child in pairs(p.EditableChildren) do
				table.insert(t.children, generate_json(child))
			end
		else
			t.children = nil
		end
		return t
	end

	local json = generate_json {
		EditableChildren = ttt.hud.bases
	}

	file.Write("tttrw/hud.json", util.TableToJSON({
		variables = ttt.hud.current.variables,
		elements = json.children
	}, true))

	init_hud()
end

function PANEL:DoUpdate()
	local pnl = self.EditPanel
	if (not IsValid(pnl)) then
		self.UpdateButton:SetDisabled(true)
		return
	end

	local built_json = {}
	local frameupdate = {}

	for _, option in ipairs(self.Options) do
		built_json[option.Key:GetText()] = tovalue(option.Value:GetText())
		if (option.FrameUpdate:GetChecked()) then
			table.insert(frameupdate, option.Key:GetText())
		end
	end

	if (#frameupdate > 0) then
		built_json.frameupdate = frameupdate
	end

	for key, value in pairs(built_json) do
		local err = pnl:Set(key, value)
		if (err) then
			print("ERROR", key, err)
			return
		end
	end

	self.SaveButton:SetDisabled(false)
end

function PANEL:AddOptionPanel()
	local option = self.Scroller:Add "EditablePanel"
	option:Dock(TOP)
	option:DockPadding(4, 1, 1, 1)
	local cur_num = num
	function option.Paint(s, w, h)
		if (s:GetZPos() % 2 == 0) then
			surface.SetDrawColor(196, 196, 196, 64)
		else
			surface.SetDrawColor(255, 255, 255, 64)
		end
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0)
		surface.DrawLine(self.KeySize + 8, 0, self.KeySize + 8, h)
	end
	option:SetZPos(#self.Options)

	return option
end

function PANEL:SetupOption(option, key, value)
	option.FrameUpdate = option:Add "DCheckBox"
	option.FrameUpdate:Dock(LEFT)
	option.FrameUpdate:DockMargin(0, 2, 8, 2)
	option.FrameUpdate:SetTooltip "Should this key be set every frame?"
	function option.FrameUpdate:PerformLayout(w, h)
		self:SetWide(h)
	end

	option.Key = option:Add "tttrw_label"
	option.Key:Dock(LEFT)
	option.Key:SetContentAlignment(4)
	option.Key:SetText(key)
	option.Key:SetTextColor(Color(0, 0, 0))
	option.Key:SizeToContentsX()
	option.Key:DockMargin(0, 0, 16, 0)

	option.Value = option:Add "DTextEntry"
	option.Value:Dock(FILL)
	local txt = istable(value) and util.TableToJSON(value) or isnumber(value) and value or string.format("%q", tostring(value))
	option.Value:SetText(txt) -- pain

	option.RemoveButton = option:Add "DImage"
	option.RemoveButton:Dock(RIGHT)
	option.RemoveButton:DockMargin(2, 2, 0, 2)
	option.RemoveButton:SetImage "icon16/cross.png"
	option.RemoveButton:SetMouseInputEnabled(true)
	option.RemoveButton:SetCursor "hand"
	function option.RemoveButton.OnMousePressed(s, m)
		if (m == MOUSE_LEFT) then
			for _, option2 in ipairs(option:GetParent():GetChildren()) do
				if (option2:GetZPos() > option:GetZPos()) then
					option2:SetZPos(option2:GetZPos() - 1)
				end
			end
			self.EditPanel:Set(option.Key:GetText(), nil)

			table.RemoveByValue(self.Options, option)
			option:Remove()
			self:CreateNewOption()
		end
	end
	function option.RemoveButton:PerformLayout(w, h)
		self:SetWide(h)
	end

	option:InvalidateLayout(true)
	for _, child in pairs(option:GetChildren()) do
		child:InvalidateLayout(true)
	end

	table.insert(self.Options, option)
	local old_size = self.KeySize

	self.KeySize = math.max(option.Key:GetWide() + option.Key:GetPos(), self.KeySize)
	option.Key:SetWide(self.KeySize - option.Key:GetPos())
	if (old_size ~= self.KeySize) then
		for _, option in ipairs(self.Options) do
			option.Key:SetWide(self.KeySize - option.Key:GetPos())
		end
	end
end

function PANEL:CreateNewOption()
	if (IsValid(self.AddOption)) then
		self.AddOption:Remove()
	end

	self.AddOption = self:AddOptionPanel()
	local selector = self.AddOption:Add "DComboBox"
	selector:Dock(LEFT)
	selector:SetWide(self.KeySize)
	local used_already = {}
	for _, option in ipairs(self.Options) do
		used_already[option.Key:GetText():lower()] = true
	end

	local found = false
	for name in pairs(self.EditPanel.Inputs.list) do
		local inp = name:match "^Set(.+)$"
		if (not inp) then
			continue
		end
		inp = inp:lower()

		if (used_already[inp]) then
			continue
		end

		selector:AddChoice(inp)

		found = true
	end

	function selector.OnSelect(s, _, value)
		s:Remove()
		self:SetupOption(self.AddOption, value, "")
		self.AddOption = nil
		self:CreateNewOption()
	end

	if (not found) then
		self.AddOption:Remove()
	end
end

function PANEL:AddOptions(json)
	for _, option in ipairs(self.Options or {}) do
		option:Remove()
	end

	self.Options = {}
	self.KeySize = 0
	for key, value in SortedPairs(json) do
		if (key == "children" or key == "name") then
			continue
		end
		if (key == "frameupdate") then
			self.Options.FrameUpdate = value
			continue
		end

		local option = self:AddOptionPanel()
		self:SetupOption(option, key, value)
	end

	self:CreateNewOption()

	for _, option in ipairs(self.Options) do
		option.FrameUpdate:SetChecked(table.HasValue(self.Options.FrameUpdate or {}, option.Key:GetText()))
	end
end

function PANEL:SetEditPanel(p)
	self.EditPanel = p
	self:AddOptions(p.TTTRWHUDElement)
	self.UpdateButton:SetDisabled(false)

	self:OnPanelEditing(p)
end

vgui.Register("tttrw_hud_edit_panel", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:GetHUDNode(pnl)
	if (self.Nodes[pnl] or not IsValid(pnl)) then
		return self.Nodes[pnl] or self.BaseNode
	end

	local parent = pnl:GetEditableParent()
	local tree = self:GetHUDNode(parent)
	self.Nodes[pnl] = tree:AddNode(pnl:GetName())
	self.Nodes[pnl].HUDPanel = pnl
	self.Nodes[pnl].DoRightClick = self.NodeRightClick
	return self.Nodes[pnl]
end

function PANEL:Init()
	ttt.HUDElement:SetParent()
	ttt.HUDElement:SetMouseInputEnabled(true)
	self:SetTitle "HUD Editor"
	self:SetWide(500 + 260)

	self.Tree = self:Add "ttt_curved_panel"
	self.Tree:Dock(RIGHT)
	self.Tree:SetWide(260)
	self.Tree:DockMargin(4, 0, 0, 0)

	self.Inner = self:Add "tttrw_hud_edit_panel"
	self.Inner:Dock(TOP)
	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
	self:Center()


	self.Tree.Tree = self.Tree:Add "DTree"
	self.Tree.Tree:Dock(FILL)
	self.Tree.Tree:SetPaintBackground(false)
	function self.Tree.Tree.OnNodeSelected(s, node)
		if (IsValid(node.HUDPanel)) then
			self.Inner:SetEditPanel(node.HUDPanel)
		end
	end
	self.BaseNode = self.Tree.Tree:AddNode "GMod HUD Base"
	function self.NodeRightClick(s)
		local mn = DermaMenu()
		mn:AddOption("New", function()
			local p = ttt.hud.create({element = "base"}, s and s.HUDPanel or nil)
			if (IsValid(s.HUDPanel)) then
				s.HUDPanel.EditableChildren = s.HUDPanel.EditableChildren or {}
				table.insert(s.HUDPanel.EditableChildren, p)
			end
			self:GetHUDNode(p)
		end)
		if (IsValid(s.HUDPanel)) then
			mn:AddOption("Rename", function()
				Derma_StringRequest("Rename", "New name for " .. s:GetText(), s:GetText(), function(new)
					s.HUDPanel:Set("name", new)
					s:SetText(new)
				end)
			end)
			mn:AddOption("Delete", function()
				local pnl = s.HUDPanel
				local parent = s.HUDPanel:GetEditableParent()
				if (not IsValid(parent)) then
					table.RemoveByValue(ttt.hud.bases, pnl)
				elseif (parent and parent.EditableChildren) then
					table.RemoveByValue(parent.EditableChildren, pnl)
				end
				s:Remove()
			end)
			self.Inner:SetEditPanel(s.HUDPanel)
		end
		mn:Open()
	end
	self.BaseNode.DoRightClick = self.NodeRightClick
	self.Nodes = {}

	local todo = table.Copy(ttt.hud.bases)
	while (#todo ~= 0) do
		local now = todo[1]
		table.remove(todo, 1)
		self:GetHUDNode(now)
		if (now.EditableChildren) then
			for _, child in ipairs(now.EditableChildren) do
				table.insert(todo, child)
				print(child)
			end
		end
	end

	function self.Inner.OnPanelEditing(s, p)
		if (not IsValid(self.Tree.Tree:GetSelectedItem()) or self.Tree.Tree:GetSelectedItem().HUDPanel ~= p) then
			self.Tree.Tree:SetSelectedItem(self:GetHUDNode(p))
			self:GetHUDNode(p):ExpandTo(true)
		end
	end

	hook.Add("DrawOverlay", self, self.DrawOverlay)
	hook.Add("VGUIMousePressAllowed", self, self.VGUIMousePressAllowed)
end

function PANEL:OnRemove()
	ttt.HUDElement:SetMouseInputEnabled(false)
	ttt.HUDElement:SetKeyboardInputEnabled(false)
	ttt.HUDElement:SetParent(GetHUDPanel())

	if (IsValid(self.Tree)) then
		self.Tree:Remove()
	end
end

function PANEL:NotifyClicked(p)
	self.Inner:SetEditPanel(p)
end

function PANEL:VGUIMousePressAllowed(btn)
	local p = GetHoveredPanel()
	if (not p) then
		return
	end

	self:NotifyClicked(p)
	return true
end

function PANEL:Highlight(p, outline)
	local x0, y0 = p:LocalToScreen(0, 0)
	local x1, y1 = p:LocalToScreen(p:GetSize())
	local tx, ty = x0, y1
	surface.SetFont "BudgetLabel"
	local json = p.JSON
	local text = "" .. p:GetName()
	
	local w, h = surface.GetTextSize(text)

	if (w + tx > ScrW()) then
		tx = ScrW() - w
	end
	if (h + ty > ScrH()) then
		ty = ScrH() - h
	end

	if (outline) then
		surface.DrawOutlinedRect(x0 - outline, y0 - outline, outline * 2 + x1 - x0, outline * 2 + y1 - y0, outline)
	else
		surface.DrawRect(x0, y0, x1 - x0, y1 - y0)
	end

	surface.SetTextColor(white_text)
	surface.SetTextPos(tx, ty)
	surface.DrawText(text)
end

function PANEL:DrawOverlay()
	local p = GetHoveredPanel()
	if (IsValid(p)) then
		surface.SetDrawColor(100, 50, 50, 100)
		self:Highlight(p)
	end

	local p = self.Inner.EditPanel
	if (IsValid(p)) then
		surface.SetDrawColor(50, 150, 50, 255)
		self:Highlight(p, 3)
	end
end

vgui.Register("tttrw_hud_editor", PANEL, "DFrame")