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

local default = [=[[
	{
		"element": "curve",
		"color": [255, 0, 111, 0],
		"name": "bottomleft_area",
		"positioning": {
			"size": [330, 92],
			"offset": [26, 50],
			"from": "bottom"
		},
		"children": [
			{
				"element": "curve_outline",
				"dock": "left",
				"color": {
					"func": "coloralpha",
					"inputs": [
						"$$rolecolor",
						64
					]
				},
				"positioning": {
					"size": [6, 0]
				},
				"children": [
					{
						"element": "curve",
						"dock": "fill",
						"color": "$$rolecolor",
						"frameupdate": ["color"]
					}
				],
				"margin": [0, 0, 6, 0],
				"frameupdate": ["color"]
			},
			{
				"element": "base",
				"dock": "right",
				"name": "healthcontainer",
				"positioning": {
					"size": [84, 0]
				},
				"margin": [16, 0, 0, 0],
				"children": [
					{
						"element": "label",
						"dock": "fill",
						"contentalignment": 1,
						"font": {
							"font": "Roboto",
							"weight": 500,
							"size": 28
						},
						"text": "$$health",
						"margin": [0, 0, 0, 25],
						"rendersystem": "shadow",
						"frameupdate": ["text"]
					}
				]
			},
			{
				"element": "base",
				"dock": "bottom",
				"name": "rolecontainer",
				"positioning": {
					"size": [0, 18]
				},
				"margin": [0, 14, 0, 1],
				"children": [
					{
						"element": "image",
						"name": "roleimage",
						"positioning": {
							"size": [18, 18]
						},
						"dock": "left",
						"image": "$$roleicon",
						"frameupdate": ["image"]
					},
					{
						"element": "label",
						"dock": "fill",
						"contentalignment": 4,
						"margin": [6, 0, 0, 0],
						"rendersystem": "shadow",
						"font": {
							"font": "Roboto",
							"weight": 500,
							"size": 20
						},
						"text": "$$rolename",
						"frameupdate": ["text"],
						"children": [
							{
								"element": "label",
								"dock": "right",
								"contentalignment": 3,
								"color": "$$teamcolor",
								"rendersystem": "shadow",
								"text": "$$teamname",
								"frameupdate": ["text", "color"],
								"font": {
									"font": "Roboto",
									"weight": 500,
									"size": 18
								}
							}
						]
					}
				]
			},
			{
				"element": "curve_outline",
				"name": "healthbaroutline",
				"curve": 6,
				"color": "#000000",
				"dock": "bottom",
				"positioning": {
					"size": [128, 12]
				},
				"children": [
					{
						"element": "curve",
						"name": "healthbar",
						"dock": "fill",
						"curve": "inherit",
						"color": "#fff",
						"scissor": [
							0,
							0,
							{
								"func": "sub",
								"inputs": [
									1,
									{
										"func": "divide",
										"inputs": [
											"$$health",
											"$$maxhealth"
										]
									}
								]
							},
							0
						]
					},
					{
						"element": "curve",
						"name": "armorbar",
						"dock": "fill",
						"curve": "inherit",
						"color": "#555",
						"scissor": [
							0,
							7,
							{
								"func": "sub",
								"inputs": [
									1,
									{
										"func": "divide",
										"inputs": [
											"$$armor",
											"$$maxarmor"
										]
									}
								]
							},
							0
						]
					}
				]
			},
			{
				"element": "label",
				"dock": "fill",
				"margin": [0, 1, 0, 6],
				"contentalignment": 4,
				"font": {
					"font": "Roboto",
					"weight": 300,
					"size": 24
				},
				"rendersystem": "shadow",
				"text": {
					"func": "concat",
					"inputs": [
						"$$roundstate",
						": ",
						"$$timeleft"
					]
				},
				"frameupdate": ["text"],
				"children": [
					{
						"element": "label",
						"dock": "right",
						"contentalignment": 3,
						"text": "$$overtime",
						"font": {
							"font": "Roboto",
							"weight": 500,
							"size": 18
						},
						"color": "$$teamcolor",
						"rendersystem": "shadow",
						"frameupdate": ["text", "color"]
					}
				]
			}
		]
	},
	{
		"element": "base",
		"name": "gunammo",
		"positioning": {
			"size": [375, 100],
			"offset": [26, 50],
			"from": "bottom right"
		},
		"children": [
			{
				"element": "image",
				"image": "gui/gradient.png",
				"reverse": true,
				"color": {
					"func": "coloralpha",
					"inputs": ["$$guncolor", 96]
				},
				"dock": "bottom",
				"positioning": {
					"size": [0, 34]
				},
				"frameupdate": ["color"],
				"margin": [34, 4, 0, 0],
				"children": [
					{
						"element": "label",
						"dock": "right",
						"contentalignment": 6,
						"text": "$$gunname",
						"font": {
							"font": "Roboto",
							"weight": 300,
							"size": 26
						},
						"margin": [0, 0, 12, 0],
						"frameupdate": ["text"]
					}
				]
			},
			{
				"element": "curve",
				"dock": "bottom",
				"name": "gundivider",
				"positioning": {
					"size": [0, 1]
				},
				"color": "#888",
				"margin": [0, 4, 0, 0]
			},
			{
				"element": "base",
				"dock": "fill",
				"name": "ammocontainer",
				"children": [
					{
						"element": "curve",
						"curve": 4,
						"color": [20, 20, 20, 208],
						"dock": "right",
						"margin": [0, 4, 0, 12],
						"sizeto": {
							"what": "children",
							"width": true
						},
						"padding": [6, 0, 6, 0],
						"frameupdate": ["sizeto"],
						"children": [
							{
								"element": "label",
								"contentalignment": 5,
								"text": "$$gunreserves",
								"rendersystem": "shadow",
								"sizeto": "contents",
								"frameupdate": ["text", "sizeto", "center"],
								"font": {
									"font": "Roboto",
									"weight": 300,
									"size": 32
								}
							}
						]
					},
					{
						"element": "label",
						"dock": "right",
						"contentalignment": 3,
						"margin": [0, 0, 16, 0],
						"text": "$$gunammo",
						"font": {
							"font": "Roboto",
							"weight": 300,
							"size": 64
						},
						"frameupdate": ["text"]
					}
				]
			}
		]
	}
]]=]

local function init_hud()
	local json
	
	local s, e = pcall(function()
		json = util.JSONToTable(file.Read("tttrw_hud.json", "DATA") or default)
	end)
	
	if (not s or not json) then
		warn("%s", e or "json ded")
		return
	end

	if (IsValid(ttt.HUDElement)) then
		ttt.HUDElement:Remove()
	end

	ttt.HUDElement = vgui.Create "EditablePanel"
	ttt.HUDElement:ParentToHUD()
	ttt.HUDElement:SetSize(ScrW(), ScrH())

	for id, data in ipairs(json) do
		local p, err = ttt.hud.create(data, ttt.HUDElement)
		if (not p) then
			print(p, err)
		end
	end
end

hook.Add("HUDPaint", "tttrw_hud_init", function()
	init_hud()
	hook.Remove("HUDPaint", "tttrw_hud_init")
end)

hook.Add("OnScreenSizeChanged", init_hud)

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

hook.Add("DrawOverlay", "tttrw_edit_hud", function()
	local p = GetHoveredPanel()
	if (not p) then
		return
	end

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

	surface.SetTextColor(white_text)
	surface.SetDrawColor(100, 50, 50, 100)

	surface.SetTextPos(tx, ty)
	surface.DrawText(text)

	surface.DrawRect(x0, y0, x1 - x0, y1 - y0)
end)

ttt.hudeditor = ttt.hudeditor or {
	Events = setmetatable({}, {
		__index = function(self, k)
			self[k] = {}
			return self[k]
		end
	})
}
function ttt.hudeditor:Hook(event, name, fn)
	self.Events[event][name] = fn
end

function ttt.hudeditor:Init()
	self.Valid = true
	for event in pairs(self.Events) do
		hook.Add(event, self, function(self, ...)
			for _, event in pairs(self.Events[event]) do
				event(self, ...)
			end
		end)
	end
end

function ttt.hudeditor:Destroy()
	self.Valid = false
end

function ttt.hudeditor:IsValid()
	return self.Valid
end


ttt.hudeditor:Hook("DrawOverlay", "selector", function(self)
	surface.SetDrawColor(0, 0, 255)
	surface.DrawRect(0, 0, 25, 25)
end)

ttt.hudeditor:Destroy()

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