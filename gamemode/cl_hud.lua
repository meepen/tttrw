DEFINE_BASECLASS "gamemode_base"

local DrawTextShadowed = hud.DrawTextShadowed

local health_full = Color(58, 180, 80)
local health_ok = Color(240, 255, 0)
local health_dead = Color(255, 51, 0)

local function ColorLerp(col_from, col_mid, col_to, amt)
	if (amt > 0.5) then
		col_from = col_mid
		amt = (amt - 0.5) * 2
	else
		col_to = col_mid
		amt = amt * 2
	end

	local fr, fg, fb = col_from.r, col_from.g, col_from.b
	local tr, tg, tb = col_to.r, col_to.g, col_to.b

	return fr + (tr - fr) * amt, fg + (tg - fg) * amt, fb + (tb - fb) * amt
end

function ttt.GetHUDTarget()
	local ply = LocalPlayer()
	if (ply.GetObserverMode and (ply:GetObserverMode() == OBS_MODE_IN_EYE or ply:GetObserverMode() == OBS_MODE_CHASE)) then
		if (ply:GetObserverTarget():IsPlayer()) then
			return ply:GetObserverTarget()
		end
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

	local target

	if (ent:IsPlayer()) then
		if (ent.HasDisguiser and ent:HasDisguiser()) then return end

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
			local txt = role.Name

			tw, th = surface.GetTextSize(txt)

			hud.DrawTextOutlined(txt, col, color_black, x - tw / 2, y, 1)
		end

		local health, maxhealth = ent:Health(), ent:GetMaxHealth()

		local scrw = ScrW()

		local hppct = health / maxhealth
		local wid = math.max(40, math.min(scrw / 45, 100))
		local hpw = math.ceil(wid * hppct)
		y = y + th + 4

		local r, g, b = ColorLerp(health_dead, health_ok, health_full, hppct)
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
	CHudSecondaryAmmo = true
}

function GM:HUDShouldDraw(name)
	if (hide[name]) then
		return false
	end
	
	return true
end

--[[
	
	self:SetSize(ScrW() * 0.22, ScrH() * 0.04)
	self:SetCurve(math.Round(ScrH() * 0.0025) * 2)
	self:SetPos(ScrW() * 0.05, ScrH() - ScrH() * 0.1)
]]

local default = [[
[
	{
		"name": "SpectatingOverlay",
		"type": "ttt_curve_outline",
		"pos": [0.5, 0.1, 0],
		"size": [0.18, 0.036],
		"curve": 0.005,
		"bg_color": "role",
		"outline_color": [12, 13, 12, 255],
		"disappear_no_target": true,
		"children": [
			{
				"name": "SpectatorText",
				"type": "ttt_text",
				"color": "white",
				"text": [
					"Spectating %s",
					"target_name"
				],
				"font": {
					"size": 0.024,
					"font": "Lato",
					"weight": 1000
				},
				"dock": "fill"
			}
		]
	},
	{
		"name": "PropPunchBackground",
		"type": "ttt_curve",
		"bg_color": "black_bg",
		"pos": [0.5, 0.9, 0],
		"size": [0.18, 0.036],
		"disappear_no_prop": true,
		"curve": 0.004,
		"children": [
			{
				"name": "PropPunchOverlay",
				"type": "ttt_curve_outline",
				"dock": "fill",
				"curve": 0.005,
				"frac": "prop_punches_frac",
				"bg_color": {
					"func": "lerp",
					"frac": "prop_punches_frac",
					"points": [
						[200, 49, 59],
						[153, 129, 6],
						[59, 171, 91]
					]
				},
				"outline_color": [12, 13, 12, 255],
				"children": [
					{
						"name": "PropPunchText",
						"type": "ttt_text",
						"color": "white",
						"text": [
							"Prop Punches"
						],
						"font": {
							"size": 0.024,
							"font": "Lato",
							"weight": 1000
						},
						"dock": "fill"
					}
				]
			}
		]
	},
	{
		"name": "BottomLeft",
		"type": "ttt_curve",
		"bg_color": [0, 0, 0, 0],
		"pos": [0.1, 0.93, 1],
		"size": [0.18, 0.1],
		"curve": 0.004,
		"curvetargets": {
			"topleft": false,
			"topright": false
		},
		"children": [
			{
				"name": "HealthBackground",
				"type": "ttt_curve",
				"bg_color": "black_bg",
				"dock": "top",
				"size": [0.22, 0.036],
				"pos": [0, 0, 2],
				"curve": 0.004,
				"children": [
					{
						"name": "HealthBar",
						"type": "ttt_curve_outline",
						"bg_color": {
							"func": "lerp",
							"frac": "health_frac",
							"points": [
								[200, 49, 59],
								[153, 129, 6],
								[59, 171, 91]
							]
						},
						"curvetargets": {
							"topleft": false,
							"topright": false
						},
						"outline_color": [12, 13, 12, 255],
						"dock": "fill",
						"frac": "health_frac",
						"curve": 0.004,
						"children": [
							{
								"name": "HealthText",
								"type": "ttt_text",
								"color": "white",
								"text": [
									"%i / %i",
									"health",
									"health_max"
								],
								"font": {
									"size": 0.024,
									"font": "Lato",
									"weight": 1000
								},
								"dock": "fill"
							}
						]
					}
				]
			},
			{
				"name": "Divider",
				"type": "ttt_curve",
				"dock": "top",
				"pos": [0, 0, 1],
				"size": [0, 0.002],
				"bg_color": [0, 0, 0, 0],
				"curve": 0.004,
				"curvetargets": {
					"topleft": false,
					"topright": false,
					"bottomleft": false,
					"bottomright": false
				}
			},
			{
				"name": "RoleAndTimeBar",
				"type": "ttt_curve_outline",
				"pos": [0.12, 0.95, 0],
				"dock": "top",
				"size": [0.22, 0.036],
				"curve": 0.004,
				"bg_color": "role",
				"outline_color": [12, 13, 12, 255],

				"curvetargets": {
					"bottomleft": false,
					"bottomright": false
				},

				"padding": [0.15, 0, 0.15, 0],
				"children": [
					{
						"name": "TimeText",
						"type": "ttt_text",
						"color": "white",
						"text": [
							"%s",
							"time_remaining_pretty"
						],
						"font": {
							"size": 0.024,
							"font": "Lato",
							"weight": 1000
						},
						"dock": "fill",
						"align": "right"
					},
					{
						"name": "RoleText",
						"type": "ttt_text",
						"color": "white",
						"text": [
							"%s",
							"role_name"
						],
						"font": {
							"size": 0.024,
							"font": "Lato",
							"weight": 1000
						},
						"dock": "fill",
						"align": "left"
					}
				]
			}
		]
	},
	{
		"name": "BottomRight",
		"type": "ttt_curve",
		"bg_color": [0, 0, 0, 0],
		"pos": [0.9, 0.93, 0],
		"size": [0.18, 0.1],
		"curve": 0.004,
		"children": [
			{
				"name": "AmmoBackground",
				"type": "ttt_curve",
				"bg_color": "black_bg",
				"dock": "top",
				"size": [0.22, 0.036],
				"pos": [0, 0, 1],
				"curve": 0.004,
				"children": [
					{
						"name": "AmmoBar",
						"type": "ttt_curve_outline",
						"bg_color": {
							"func": "lerp",
							"frac": "clip_frac",
							"points": [
								[200, 49, 59],
								[153, 129, 6],
								[59, 171, 91]
							]
						},
						"outline_color": [12, 13, 12, 255],
						"dock": "fill",
						"frac": "clip_frac",
						"curve": 0.004,
						"children": [
							{
								"name": "AmmoClip2",
								"type": "ttt_text",
								"color": "white",
								"text": [
									"%s",
									"clip_pretty"
								],
								"font": {
									"size": 0.024,
									"font": "Lato",
									"weight": 1000
								},
								"dock": "fill",
								"children": [
									{
										"name": "WeaponShadow",
										"type": "ttt_weapon",
										"color": [0, 0, 0, 0],
										"dock": "right",
										"color": "white",
										"size": [0.028, 0]
									}
								]
							}
						]
					}
				]
			}
		]
	},
	{
		"name": "WeaponSelect",
		"type": "ttt_weapon_select"
	}
]
]]

local json

local s, e = pcall(function()
	json = util.JSONToTable(file.Read("tttrw_hud.json", "DATA") or default)
end)

if (not s or not json) then
	warn("%s", not json and "json ded" or e)
	return
end

ttt.HUDElements = ttt.HUDElements or {}

for item, ele in pairs(ttt.HUDElements) do
	if (IsValid(ele)) then
		ele:Remove()
	end
end

if (IsValid(ttt.HUDElement)) then
	ttt.HUDElement:Remove()
end

ttt.HUDElement = vgui.Create "EditablePanel"

ttt.HUDElement:SetParent(GetHUDPanel())
ttt.HUDElement:SetSize(GetHUDPanel():GetSize())

local function IsCustomizable(ele)
	local s, base = pcall(baseclass.Get, ele)

	if (not s) then
		return false
	end
	
	while (base) do
		if (base.AcceptInput) then
			return true
		end
		if (not base.Base) then
			return false
		end
		base = baseclass.Get(base.Base)
		if (not base) then
			return false
		end
	end
end

local function CreateItem(data, parent)
	if (not data.type or not IsCustomizable(data.type) or not data.name) then
		warn("Couldn't create %s", data.name or data.type)
		return
	end

	if (parent.GetCustomizeParent) then
		parent = parent:GetCustomizeParent()
	end

	if (not IsValid(parent)) then
		warn("Couldn't create %s: no parent", data.name or data.type)
		return
	end

	local p = parent:Add(data.type)
	p:SetMouseInputEnabled(true)
	p.JSON = data
	p.CustomizeParent = parent

	p:SetName(data.name)

	for key, value in pairs(data) do
		p:AcceptInput(key, value)
	end

	if (data.children) then
		if (p.GetCustomizeParent) then
			p = p:GetCustomizeParent()
		end

		for _, child in ipairs(data.children) do
			CreateItem(child, p)
		end
	end
end

for id, data in ipairs(json) do
	CreateItem(data, ttt.HUDElement)
end

local function GetHoveredPanel()
	local p = vgui.GetHoveredPanel()
	while (p) do
		if (p.JSON) then
			break
		end
		p = p:GetParent()
	end

	if (not p or not p.JSON) then
		return
	end
	
	return p
end


hook.Add("DrawOverlay", "cancer", function()
	local p = GetHoveredPanel()
	if (not p) then
		return
	end

	local x0, y0 = p:LocalToScreen(0, 0)
	local x1, y1 = p:LocalToScreen(p:GetSize())
	local tx, ty = x0, y1
	surface.SetFont "BudgetLabel"
	local json = p.JSON
	local text = "[" .. p:GetName() .. "]"
	if (p.JSON.dock) then
		text = text .. " dock:" .. p.JSON.dock
	elseif (p.JSON.pos) then
		text = text .. " pos:[" .. p.JSON.pos[1] .. "," .. p.JSON.pos[2] .. "]"
	end

	if (p.JSON.size) then
		text = text .. " size:[" .. p.JSON.size[1] .. "," .. p.JSON.size[2] .. "]"
	end

	if (p.JSON.pos and p.JSON.pos[3]) then
		text = text .. " z:" .. p.JSON.pos[3]
	end

	local w, h = surface.GetTextSize(text)

	if (w + tx > ScrW()) then
		tx = ScrW() - w
	end
	if (h + ty > ScrH()) then
		ty = ScrH() - h
	end

	surface.SetTextColor(white_text)
	surface.SetDrawColor(100, 50, 50, 100)

	surface.SetTextPos(tx, ty)
	surface.DrawText(text)

	surface.DrawRect(x0, y0, x1 - x0, y1 - y0)
end)

concommand.Add("tttrw_edit_hud", function()
	local parent = ttt.HUDElement:GetParent()

	if (parent == GetHUDPanel()) then
		ttt.HUDElement:SetParent()
		ttt.HUDElement:MakePopup()
		ttt.HUDElement:SetKeyboardInputEnabled(false)
	else
		ttt.HUDElement:SetMouseInputEnabled(false)
		ttt.HUDElement:SetKeyboardInputEnabled(false)
		ttt.HUDElement:SetParent(GetHUDPanel())
	end
end)