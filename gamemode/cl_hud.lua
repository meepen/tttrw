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
	local ent = hook.Run("GetSpectatingEntity", LocalPlayer())

	if (not IsValid(ent)) then
		ent = LocalPlayer()
	end
	return ent
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
end


local hide = {
	CHudHealth = true,
	CHudDamageIndicator = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
	CHudCrosshair = true
}

hook.Add("HUDShouldDraw", "TTTHud", function(name)
	if (hide[name]) then
		return false
	end
end)


local hide_when_chat_open = CreateConVar("ttt_hide_hud_when_chat_open", "0", FCVAR_ARCHIVE)


local self = {}

function self:GetTarget()
	return GetHUDTarget()
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
	
	self.OldHealth = self:GetTarget():Health()
	self.OldMaxHealth = self:GetTarget():GetMaxHealth()
	
	self:Call(string.format("setText(%d, %d);", self.OldHealth, self.OldMaxHealth))
end

function self:Paint()
	local hp = self:GetTarget():Health()
	if (self.OldHealth ~= hp) then
		self:Call(string.format("setHealth(%d);", hp))
		self.OldHealth = hp
	end
	
	local maxhp = self:GetTarget():GetMaxHealth()
	if (self.OldMaxHealth ~= maxhp) then
		self:Call(string.format("setMaxHealth(%d);", maxhp))
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
		<body onload="ttt.ready()">
			<svg id="svgBorder" class="shadow" width="320" height="48">
				<rect id="svgRect" x="2" y="5" rx="3" ry="3" width="316" height="36"
					style="fill:black; stroke:#F7F7F7; stroke-width:2; fill-opacity:0.4; stroke-opacity:1" />
			</svg>
			<svg id="svgTime" width="320" height="48">
				<rect id="svgRect" x="4" y="7" rx="1" ry="1" width="312" height="32"
					style="fill:#c91d1d; stroke:#c91d1d; stroke-width:2; fill-opacity:1; stroke-opacity:1"/>
				<text id="svgState_Text" class="hp" x="30%" y="24" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
				<text id="svgTime_Text" class="hp" x="70%" y="25" dominant-baseline="middle" fill="#F7F7F7" text-anchor="middle"></text>
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
	timer.Create("ttt_DHTML_Time_Timer", 0.05, 0, function() self:Draw() end)
end

function self:OnRemove()
	timer.Destroy("ttt_DHTML_Time_Timer")
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
	self:Call(string.format("setState(\"%s\", \"rgb(%d, %d, %d)\");", text, color.r, color.g, color.b))
end

function self:OnRoundStateChange(old, new)
	self:UpdateState(new)
end

function self:PerformLayout()
	self:SetHTML(self.Html)
	
	if (not ttt.GetRoundState) then return end

	self:UpdateState(ttt.GetRoundState())
end

function self:Draw()
	if (not self.Ready) then return end

	local other_text = string.FormattedTime(math.max(0, ttt.GetRoundTime() - CurTime()), "%02i:%02i")
	local pct = math.Clamp(1 - ((CurTime() - self.StartTime) / (ttt.GetRoundTime() - self.StartTime)), 0, 1)
	self:Call(string.format("setTime(\"%s\", %f);", other_text, pct))
end

vgui.Register("ttt_DHTML_Time", self, "ttt_DHTML")

local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

vgui.Register("ttt_crosshairs", {
	Paint = function(self, w, h)
		local r = tttrw_crosshair_color_r:GetInt()
		local g = tttrw_crosshair_color_g:GetInt()
		local b = tttrw_crosshair_color_b:GetInt()

		local t = tttrw_crosshair_thickness:GetInt()
		local len = tttrw_crosshair_length:GetInt()
		local gap = tttrw_crosshair_gap:GetInt()*2
		local opacity = tttrw_crosshair_opacity:GetInt()
		local oopacity = tttrw_crosshair_outline_opacity:GetInt()

		local dot = tttrw_crosshair_dot_size:GetInt()
		local dopacity = tttrw_crosshair_dot_opacity:GetInt()

		local s = len*2+gap
		local startw = w/2-s/2
		local starth = h/2-s/2
		
		if (len > 0 and t > 0) then
			surface.SetDrawColor(0,0,0,oopacity*255) -- outlines, counterclockwise
			surface.DrawRect(w/2-t/2-1,starth-1,t+2,len+2)
			surface.DrawRect(startw-1,h/2-t/2-1,len+2,t+2)
			surface.DrawRect(w/2-t/2-1,starth+s-len-1,t+2,len+2)
			surface.DrawRect(startw+s-len-1,h/2-t/2-1,len+2,t+2)

			surface.SetDrawColor(r,g,b,opacity) -- crosshairs, counterclockwise
			surface.DrawRect(w/2-t/2,starth,t,len)
			surface.DrawRect(startw,h/2-t/2,len,t)
			surface.DrawRect(w/2-t/2,starth+s-len,t,len)
			surface.DrawRect(startw+s-len,h/2-t/2,len,t)
		end

		if (dot > 0) then
			draw.NoTexture()

			surface.SetDrawColor(0,0,0,oopacity*255)
			drawCircle(startw+s/2,starth+s/2,dot+2,45)

			surface.SetDrawColor(r,g,b,dopacity)
			drawCircle(startw+s/2,starth+s/2,dot,45)
		end
	end
})

if (ttt.HUDHealthPanel) then
	ttt.HUDHealthPanel:Remove()
end

if (ttt.HUDRolePanel) then
	ttt.HUDRolePanel:Remove()
end

if (ttt.Crosshair) then
	ttt.Crosshair:Remove()
end

ttt.Crosshair = vgui.Create("ttt_crosshairs", GetHUDPanel())
ttt.Crosshair:SetPos(0,0)
ttt.Crosshair:SetSize(ScrW(),ScrH())

ttt.HUDHealthPanel = vgui.Create("ttt_DHTML_Health", GetHUDPanel())
ttt.HUDHealthPanel:SetPos(100, ScrH() - 150)
ttt.HUDHealthPanel:SetSize(500, 300)

ttt.HUDRolePanel = vgui.Create("ttt_DHTML_Time", GetHUDPanel())
local w = 328
ttt.HUDRolePanel:SetPos(ScrW() / 2 - w / 2, 15)
ttt.HUDRolePanel:SetSize(w, 300)
