local tttrw_force_ammo_bar = CreateConVar("tttrw_force_ammo_bar", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "Force TTTRW HUD to use a bar for ammo")
--local tttrw_crosshair_shape = CreateConVar("tttrw_crosshair_shape", "crosshair", {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_r = CreateConVar("tttrw_crosshair_color_r", 232, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_g = CreateConVar("tttrw_crosshair_color_g", 80, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_b = CreateConVar("tttrw_crosshair_color_b", 94, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_thickness = CreateConVar("tttrw_crosshair_thickness", 2, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_length = CreateConVar("tttrw_crosshair_length", 7, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_gap = CreateConVar("tttrw_crosshair_gap", 3, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_opacity = CreateConVar("tttrw_crosshair_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_outline_opacity = CreateConVar("tttrw_crosshair_outline_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_size = CreateConVar("tttrw_crosshair_dot_size", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_opacity = CreateConVar("tttrw_crosshair_dot_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

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

local function GetHUDTarget()
	local ply = LocalPlayer()
	if (ply:GetObserverMode() == OBS_MODE_IN_EYE) then
		return ply:GetObserverTarget()
	end
	return ply
end

local white_text = Color(230, 230, 230, 255)
local status_color = Color(154, 153, 153)

local LastTarget, LastTime

function GM:HUDDrawTargetID()
	local ent = GetHUDTarget()
	local tr = ent:GetEyeTrace()

	ent = tr.Entity


	if (IsValid(ent) and ent:IsPlayer()) then
		if (ent.HasDisguiser and ent:HasDisguiser()) then return end
		
		if (LastTarget ~= ent or LastTime and LastTime < CurTime() - 1) then
			LastTarget = ent
			LastTime = CurTime()
			net.Start "ttt_player_target"
				net.WriteEntity(ent)
			net.SendToServer()
		end

		surface.SetFont "TargetIDSmall"

		local nick = ent:Nick()
		local health = ent:Health()

		surface.SetTextColor(color_black)

		local x, y = ScrW() / 2, ScrH() / 2

		y = y + math.max(50, ScrH() / 20)

		local text = nick
		local tw, th = surface.GetTextSize(text)

		hud.DrawTextOutlined(text, white_text, color_black, x - tw / 2, y, 1)

		local state = ent.HiddenState

		if (IsValid(state) and not state:IsDormant()) then
			y = y + th + 4
			local role = ttt.roles[ent:GetRole()]
			if (role) then
				local col = role.Color
				local txt = role.Name

				tw, th = surface.GetTextSize(txt)

				hud.DrawTextOutlined(txt, col, color_black, x - tw / 2, y, 1)
			end
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

function GM:HUDPaint()
	hook.Run "HUDDrawTargetID"

	hook.Run "TTTDrawHitmarkers"

	local targ = GetHUDTarget()
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

	local targ = GetHUDTarget()

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

local hide_when_chat_open = CreateConVar("ttt_hide_hud_when_chat_open", "0", FCVAR_ARCHIVE)


local self = {}

function self:GetTarget()
	return GetHUDTarget()
end

function self:CallSafe(s, ...)
	local args = {...}
	for i = 1, #args do
		args[i] = string.JavascriptSafe(tostring(args[i]))
	end
	
	self:Call(string.format(s, unpack(args)))
end

vgui.Register("ttt_DHTML", self, "DHTML")


local self = {}

function self:Init()
	self.Html = [[
		<head>
			<link href='http://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
			<style>
				* {
				  -webkit-font-smoothing: antialiased;
				  -moz-osx-font-smoothing: grayscale;
				}

				svg {
					position: absolute;
					z-index: -1
				}
				.hp {
					font-size: 23px;
					font-family: 'Lato', sans-serif;
					font-weight: bold;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
				}
				.shadow {
				  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				}
			</style>
		</head>
		<body>
			<img src="asset://garrysmod/materials/tttrw/heart.png" height="48">
			<svg id="svgBorder" class="shadow" width="390" height="48">
				<rect id="svgRect" x="10" y="5" rx="3" ry="3" width="377" height="36"
					style="fill:black; stroke:#F7F7F7; stroke-width:2; fill-opacity:0.4; stroke-opacity:1" />
			</svg>
			<svg id="svgHealth" width="390" height="48">
				<rect id="svgRect" x="12" y="7" rx="1" ry="1" width="250" height="32"
					style="fill:#39ac56; stroke:#39ac56; stroke-width:2; fill-opacity:1; stroke-opacity:1"/>
				<text id="svgText" class="hp" x="50%" y="26" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
			</svg>
			
			<script>
				var svg = document.getElementById("svgHealth");
				var text = svg.getElementById("svgText");
				var rect = svg.getElementById("svgRect");
				
				var svgBorder = document.getElementById("svgBorder");
				var borderRect = svgBorder.getElementById("svgRect");
				
				var hp = 100;
				var maxhp = 100;
				var pct = hp / maxhp;
				
				
				var maxWidth = borderRect.getAttributeNS(null, "width") - 4;
				var width = maxWidth;
				
				function changeBar()
				{
					pct = hp / maxhp;
					width = maxWidth * pct
					rect.setAttributeNS(null, "width", width)
				}
				
				function setHealth(_hp)
				{
					hp = _hp;
					text.textContent = _hp + "/" + maxhp;
					changeBar();
				}
				
				function setMaxHealth(_maxhp)
				{
					maxhp = _maxhp;
					text.textContent = hp + "/" + _maxhp;
					changeBar();
				}
				
				function setText(_hp, _maxhp)
				{
					hp = _hp;
					maxhp = _maxhp;
					text.textContent = _hp + "/" + _maxhp;
					changeBar();
				}
			</script>
		</body>
	]]
	
	self.OldHealth = 0
	self.OldMaxHealth = 0
end

function self:PerformLayout()
	self:SetHTML(self.Html)
	
	local health = math.max(self:GetTarget():Health(), 0)
	
	self.OldHealth = health
	self.OldMaxHealth = self:GetTarget():GetMaxHealth()
	
	self:CallSafe([[setText(%d, %d);]], health, self.OldMaxHealth)
end

function self:Paint()
	local hp = math.max(self:GetTarget():Health(), 0)
	if (self.OldHealth ~= hp) then
		self:CallSafe([[setHealth(%d);]], hp)
		self.OldHealth = hp
	end
	
	local maxhp = self:GetTarget():GetMaxHealth()
	if (self.OldMaxHealth ~= maxhp) then
		self:CallSafe([[setMaxHealth(%d);]], maxhp)
		self.OldMaxHealth = maxhp
	end
end

vgui.Register("ttt_DHTML_Health", self, "ttt_DHTML")


local self = {}

function self:Init()
	self:AddFunction("ttt", "ready", function()
		self.Ready = true
	end)
	
	self.Html = [[
		<head>
			<link href='http://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
			<style>
				* {
				  -webkit-font-smoothing: antialiased;
				  -moz-osx-font-smoothing: grayscale;
				}

				svg {
					position: absolute;
					z-index: -1
				}
				.text {
					font-size: 23px;
					font-family: 'Lato', sans-serif;
					font-weight: bold;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
				}
				.shadow {
				  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				}
			</style>
		</head>
		<body onload="ttt.ready()">
			<svg id="svgBorder" class="shadow" width="320" height="48">
				<rect id="svgRect" x="2" y="5" rx="3" ry="3" width="316" height="36"
					style="fill:black; stroke:#F7F7F7; stroke-width:2; fill-opacity:0.4; stroke-opacity:1" />
			</svg>
			<svg id="svgTime" width="320" height="48">
				<rect id="svgRect" x="4" y="7" rx="1" ry="1" width="312" height="32"
					style="fill:#c91d1d; stroke:#c91d1d; stroke-width:2; fill-opacity:1; stroke-opacity:1"/>
				<text id="svgState_Text" class="text" x="30%" y="24" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
				<text id="svgTime_Text" class="text" x="70%" y="25" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
			</svg>
			
			<script>
				var svg = document.getElementById("svgTime");
				var text = svg.getElementById("svgState_Text");
				var time = svg.getElementById("svgTime_Text");
				var rect = svg.getElementById("svgRect");
				
				var svgBorder = document.getElementById("svgBorder");
				var borderRect = svgBorder.getElementById("svgRect");
				
				var maxWidth = borderRect.getAttributeNS(null, "width") - 4;
				var width = maxWidth;
				
				function setState(_state, _color)
				{
					text.textContent = _state
					rect.setAttributeNS(null, "style", "fill:" + _color + "; stroke:" + _color + "; stroke-width:2; fill-opacity:1; stroke-opacity:1")
				}

				function setTime(_time, _pct)
				{
					time.textContent = _time
					width = maxWidth * _pct
					rect.setAttributeNS(null, "width", width)
				}
			</script>
		</body>
	]]
	
	self.StartTime = 0
	hook.Add("OnRoundStateChange", self, self.OnRoundStateChange)
	timer.Create("ttt_DHTML_Time_Timer", 0.5, 0, function() self:Tick() end)
end

function self:UpdateState(state)
	local color, text = status_color
	if (state == ttt.ROUNDSTATE_ACTIVE) then
		text = self:GetTarget():GetRole()
		
		if (ttt.roles[text]) then
			color = ttt.roles[text].Color
		end
	else
		text = ttt.Enums.RoundState[state]
	end
	
	self.StartTime = CurTime()
	self:CallSafe([[setState("%s", "rgb(%d, %d, %d)");]], text, color.r, color.g, color.b)
end

function self:OnRoundStateChange(old, new)
	self:UpdateState(new)
end

function self:PerformLayout()
	self:SetHTML(self.Html)
	
	if (not ttt.GetRoundState) then return end

	self:UpdateState(ttt.GetRoundState())
end

function self:Tick()
	if (not self.Ready) then return end
	
	local pct = 1
	local other_text = string.FormattedTime(math.max(0, ttt.GetRoundTime() - CurTime()), "%02i:%02i")
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
		pct = math.Clamp(1 - ((CurTime() - self.StartTime) / (ttt.GetRoundTime() - self.StartTime)), 0, 1)
	end
	
	self:CallSafe([[setTime("%s", %f);]], other_text, pct)
end

vgui.Register("ttt_DHTML_Time", self, "ttt_DHTML")

local self = {}

function self:Init()
	self:AddFunction("ttt", "ready", function()
		self.Ready = true
	end)
	
	self.Html = [[
		<head>
			<link href='http://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
			<style>
				* {
				  -webkit-font-smoothing: antialiased;
				  -moz-osx-font-smoothing: grayscale;
				  line-height: 15px;
				}
				h1 {
					font-size: 30px;
					font-family: 'Lato', sans-serif;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
					color: #F7F7F7;
				}
				h2 {
					font-size: 23px;
					font-family: 'Lato', sans-serif;
					text-align: center;
					text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
					color: #F7F7F7;
				}
				.shadow {
				  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
				}
			</style>
		</head>
		<body onload="ttt.ready()">
			<h1 id="ammoCounter" class="shadow">13/30</h1>
			<h2 id="reserveAmmo" class="shadow">43</h1>
			<img src="asset://garrysmod/materials/tttrw/heart.png" width="48">
			<script>
				var ammoCounter = document.getElementById("ammoCounter");
				var reserveAmmo = document.getElementById("reserveAmmo");
				
				
				var ammo = 0;
				var maxAmmo = 0;
				
				function setAmmo(_ammo)
				{
					ammo = _ammo
					
					ammoCounter.innerHTML = _ammo + "/" + maxAmmo
				}
				
				function setMaxAmmo(_maxAmmo)
				{
					maxAmmo = _maxAmmo
					
					ammoCounter.innerHTML = ammo + "/" + _maxAmmo
				}
				
				function setAllAmmo(_ammo, _maxAmmo, _reserve)
				{
					ammo = _ammo
					maxAmmo = _maxAmmo
					
					ammoCounter.innerHTML = _ammo + "/" + _maxAmmo
					reserveAmmo.innerHTML = _reserve
				}
				
				function setReserveAmmo(_reserve)
				{
					reserveAmmo.innerHTML = _reserve
				}

			</script>
		</body>
	]]
	
	self.OldAmmo = 0
	self.ReserveAmmo = 0

	hook.Add("PlayerSwitchWeapon", self, self.PlayerSwitchWeapon)
	timer.Create("ttt_DHTML_Ammo_Timer", 0.1, 0, function() self:Tick() end)
end

function self:UpdateAllAmmo(pl, wep)
	if (not IsValid(wep)) then return end
	
	local max_bullets = wep.Primary and wep.Primary.ClipSize or wep:Clip1()
	local cur_bullets = wep:Clip1()
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	
	self.OldAmmo = cur_bullets
	self.ReserveAmmo = reserve
	
	self:CallSafe([[setAllAmmo("%s", "%s", "%s")]], cur_bullets, max_bullets, reserve)
end

function self:PlayerSwitchWeapon(pl, old, new)
	if (pl ~= self:GetTarget()) then return end

	self:UpdateAllAmmo(pl, new)
end

function self:PerformLayout()
	self:SetHTML(self.Html)
	
	local pl = self:GetTarget()
	self:UpdateAllAmmo(pl, pl:GetActiveWeapon())
end

function self:Tick()
	if (not self.Ready) then return end
	
	local pl = self:GetTarget()
	local wep = pl:GetActiveWeapon()
	if (not IsValid(wep)) then return end

	local cur_bullets = wep:Clip1()
	if (self.OldAmmo ~= cur_bullets) then
		self.OldAmmo = cur_bullets
		self:CallSafe([[setAmmo("%s")]], cur_bullets)
	end
	
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	if (self.ReserveAmmo ~= reserve) then
		self.ReserveAmmo = reserve
		self:CallSafe([[setReserveAmmo("%s")]], reserve)
	end
end
vgui.Register("ttt_DHTML_Ammo", self, "ttt_DHTML")

if (ttt.HUDHealthPanel) then
	ttt.HUDHealthPanel:Remove()
end

if (ttt.HUDRolePanel) then
	ttt.HUDRolePanel:Remove()
end

if (ttt.HUDAmmoPanel) then
	ttt.HUDAmmoPanel:Remove()
end

ttt.HUDHealthPanel = vgui.Create("ttt_DHTML_Health", GetHUDPanel())
ttt.HUDHealthPanel:SetPos(70, ScrH() - 115)
ttt.HUDHealthPanel:SetSize(500, 300)

ttt.HUDRolePanel = vgui.Create("ttt_DHTML_Time", GetHUDPanel())
local w = 328
ttt.HUDRolePanel:SetPos(ScrW() / 2 - w / 2, 15)
ttt.HUDRolePanel:SetSize(w, 300)


ttt.HUDAmmoPanel = vgui.Create("ttt_DHTML_Ammo", GetHUDPanel())
ttt.HUDAmmoPanel:SetPos(ScrW() - 230, ScrH() - 200)
ttt.HUDAmmoPanel:SetSize(200, 300)
