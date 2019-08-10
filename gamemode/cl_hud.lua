local tttrw_force_ammo_bar = CreateConVar("tttrw_force_ammo_bar", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "Force TTTRW HUD to use a bar for ammo")

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
	CHudSecondaryAmmo = true
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



if (ttt.HUDHealthPanel) then
	ttt.HUDHealthPanel:Remove()
	ttt.HUDHealthPanel = nil
end

ttt.HUDHealthPanel = vgui.Create("ttt_DHTML_Health", GetHUDPanel())
ttt.HUDHealthPanel:SetPos(150, ScrH() - 150)
ttt.HUDHealthPanel:SetSize(500, 300)
