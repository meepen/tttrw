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
	if (ply.GetObserverMode and ply:GetObserverMode() == OBS_MODE_IN_EYE) then
		return ply:GetObserverTarget()
	end
	return ply
end

white_text = Color(230, 230, 230, 255)

local LastTarget, LastTime

function GM:HUDDrawTargetID()
	local ent = ttt.GetHUDTarget()
	local tr = ent:GetEyeTrace()

	ent = tr.Entity

	if (not IsValid(ent)) then
		return
	end

	local text = "n/a"
	local extra
	local color = white_text

	local target

	if (ent:IsPlayer()) then
		if (ent.HasDisguiser and ent:HasDisguiser()) then return end

		text = ent:Nick()
	elseif (ent:GetNW2Bool("IsPlayerBody", false)) then
		local state = ent.HiddenState
		if (not IsValid(state)) then
			text = "Unidentified Body"
		else
			local own = ent.HiddenState
			color = ttt.roles[ent.HiddenState:GetRole()].Color
			if (ent.HiddenState:GetIdentified()) then
				text = own:GetNick() .. "'s Identified Body"
			else
				text = own:GetNick() .. "'s Unidentified Body"
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

	surface.SetFont "TargetID"
	surface.SetTextColor(color_black)

	local x, y = ScrW() / 2, ScrH() / 2

	y = y + math.max(50, ScrH() / 20)

	local tw, th = surface.GetTextSize(text)

	hud.DrawTextOutlined(text, color, color_black, x - tw / 2, y, 1)


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

		surface.SetDrawColor(200, 200, 200, 255)
		surface.DrawOutlinedRect(x - wid / 2 - 1, y - 1, wid + 2, th + 2)
	end
end

function GM:HUDPaintBackground()
	hook.Run "TTTDrawDamagePosition"
end

function GM:HUDPaint()
	hook.Run "HUDDrawTargetID"
	hook.Run "TTTDrawHitmarkers"

	local targ = ttt.GetHUDTarget()
	if (targ ~= LocalPlayer()) then
		-- https://github.com/Facepunch/garrysmod-issues/issues/3936
		local wep = targ:GetActiveWeapon()
		if (IsValid(wep)) then
			wep:DoDrawCrosshair(ScrW() / 2, ScrH() / 2)
		end
	end
end

function GM:PlayerPostThink()
	if (not IsFirstTimePredicted()) then
		return
	end

	local targ = ttt.GetHUDTarget()

	if (targ ~= LocalPlayer()) then
		local wep = targ:GetActiveWeapon()
		if (IsValid(wep)) then
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
		"size": [0.22, 0.04],
		"curve": 0.005,
		"bg_color": [154, 153, 153],
		"outline_color": [230, 230, 230],
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
		"name": "HealthBackground",
		"type": "ttt_curve",
		"bg_color": "black_bg",
		"pos": [0.12, 0.9, 1],
		"size": [0.22, 0.04],
		"curve": 0.005,
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
				"outline_color": "white",
				"dock": "fill",
				"frac": "health_frac",
				"curve": 0.005,
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
		"name": "RoleAndTimeBar",
		"type": "ttt_curve_outline",
		"pos": [0.12, 0.95, 0],
		"size": [0.22, 0.04],
		"curve": 0.005,
		"bg_color": "role",
		"outline_color": [230, 230, 230],
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
	},
	{
		"name": "AmmoBackground",
		"type": "ttt_curve",
		"bg_color": [0, 0, 0, 0],
		"pos": [0.915, 0.875],
		"size": [0.15, 0.2],
		"curve": 0.005,
		"children": [
			{
				"name": "AmmoClip",
				"type": "ttt_text",
				"color": "white",
				"text": [
					"%s",
					"clip_pretty"
				],
				"font": {
					"size": 0.05,
					"font": "Lato",
					"weight": 1000
				},
				"dock": "top",
				"size": [0.15, 0.05],
				"pos": [0, 0, 0]
			},
			{
				"name": "AmmoReserves",
				"type": "ttt_text",
				"color": "white",
				"text": [
					"%s",
					"reserve_pretty"
				],
				"font": {
					"size": 0.03,
					"font": "Lato",
					"weight": 1000
				},
				"dock": "top",
				"size": [0.15, 0.03],
				"pos": [0, 0, 1]
			},
			{
				"name": "WeaponShadow",
				"type": "ttt_weapon",
				"color": [0, 0, 0, 0],
				"dock": "fill",
				"color": "white"
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

	p:SetName(data.name)

	ttt.HUDElements[data.name] = p

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
	CreateItem(data, GetHUDPanel())
end
