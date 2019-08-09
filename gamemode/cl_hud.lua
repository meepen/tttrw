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


if (IsValid(ttt.HUDHealthPanel)) then
	ttt.HUDHealthPanel:Remove()
end

hook.Add("HUDShouldDraw", "TTTHud", function(name)
	if (hide[name]) then
		return false
	end
end)


local hide_when_chat_open = CreateConVar("ttt_hide_hud_when_chat_open", "0", FCVAR_ARCHIVE)

vgui.Register("ttt_hud", {
	Init = function(self)
		self.Health = vgui.Create("ttt_hud_health", self)
		self.Health:Dock(NODOCK)
		self.Health:SetZPos(1)

		--[[self.Role = vgui.Create("ttt_hud_ammo", self)
		self.Role:Dock(TOP)
		self.Role:SetZPos(0)

		self.Role2 = vgui.Create("ttt_hud_role", self)
		self.Role2:Dock(TOP)
		self.Role2:SetZPos(-1)]]
		hook.Add("StartChat", self, self.StartChat)
		hook.Add("FinishChat", self, self.FinishChat)
	end,
	StartChat = function(self)
		if (hide_when_chat_open:GetBool()) then
			self:SetVisible(false)
		end
	end,
	FinishChat = function(self)
		self:SetVisible(true)
	end,
	PerformLayout = function(self, w, h)
		hook.Run("ScreenResolutionChanged")
		local scrw, scrh = ScrW(), ScrH()
		self:SetSize(scrw, scrh)
		self:SetPos(0, 0)
		
		self.Health:SetSize(200, 500)
		self.Health:SetPos(ScrW() / 2, 1000)
		--[[local cx, cy = chat.GetChatBoxPos()
		local cw, ch = chat.GetChatBoxSize()
		self:SetSize(scrw / 5, scrh - (cy + ch) - cx)
		self:SetPos(cx, cy + ch)

vgui.Register("ttt_DHTML", self, "DHTML")


		local children = #self:GetChildren()
		local tall = math.floor((h - border_size * (children + 1)) / children)
		for _, pnl in ipairs(self:GetChildren()) do
			pnl:SetTall(tall)
		end]]

		-- 2 is always better looking
		local font_size = 2--math.floor((tall - border_size * 2) / 2) * 2

		surface.CreateFont("TTTHUDFont", {
			font = "Roboto",
			size = font_size,
			weight = 800,
			antialias = true,
			shadow = false
		})
		
		--[[surface.CreateFont("TTTHUDAmmoFontLarge", {
			font = "Roboto",
			size = math.floor((tall - border_size * 2) / 3) * 2,
			weight = 800,
			antialias = true,
			shadow = false
		})

		surface.CreateFont("TTTHUDAmmoFontSmall", {
			font = "Roboto",
			size = math.ceil((tall - border_size * 2) / 3 / 2) * 2,
			weight = 800,
			antialias = true,
			shadow = false
		})]]
	end,
	GetTarget = function()
		return GetHUDTarget()
	end,
	Paint = function(self, w, h)
		--[[local ent = GetHUDTarget()

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

		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(0, 0, w, h)]]


local icon_width = 100
local health_width = 200
local health_height = 35

vgui.Register("ttt_hud_health", {
	Paint = function(self, w, h)
		local ent = self:GetTarget()

		if (not ent:Alive()) then
			return
		end
		
		local width = w - icon_width
		
		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(icon_width, 0, width, h)
		
		local health, maxhealth = ent:Health(), ent:GetMaxHealth()
		local pct = health / maxhealth
		local lastpct = self.LastPercent or pct
		local curchange = FrameTime() * 4 -- 500% hp/s
		local change = pct - lastpct
		local curpct = change == 0 and pct or lastpct + (change / math.abs(change)) * math.min(curchange, math.abs(change))

		self.LastPercent = curpct
		
		surface.SetDrawColor(ColorLerp(health_dead, health_ok, health_full, curpct))
		surface.DrawRect(icon_width, 0, width * curpct, h)
		
		local text = string.format("%i/%i", math.max(0, ent:Health()), math.max(0, ent:GetMaxHealth()))
		
		draw.SimpleTextOutlined(
			text, "TTTHUDHealthFont", 100 + width / 2, h / 2,
			color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0, color_white
		)
		
		
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(icon_width, 0, width, h)
		
		

		--[[local health, maxhealth = ent:Health(), ent:GetMaxHealth()
		local pct = health / maxhealth
		local lastpct = self.LastPercent or pct
		local curchange = FrameTime() * 4 -- 500% hp/s
		local change = pct - lastpct
		local curpct = change == 0 and pct or lastpct + (change / math.abs(change)) * math.min(curchange, math.abs(change))

		self.LastPercent = curpct

		surface.SetDrawColor(ColorLerp(health_dead, health_ok, health_full, curpct))
		surface.DrawRect(0, 0, w * curpct, h)

		draw.SimpleTextOutlined(
			string.format("%i HP", math.max(0, ent:Health())), "TTTHUDFont", w / 2, h / 2,
			color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black
		)]]
	end,
	PerformLayout = function(self, w, h)
		local scrw, scrh = ScrW(), ScrH()
		self:SetSize(icon_width + health_width, health_height)
		self:SetPos(scrw / 10, scrh / 1.125)
		
		surface.CreateFont("TTTHUDHealthFont", {
			font = "Lato",
			size = 22,
			weight = 0,
			antialias = true,
			shadow = true
		})
	end,
	GetTarget = function()
		return GetHUDTarget()
	end
	
	self.StartTime = CurTime()
	self:Call(string.format("setState(\"%s\", \"rgb(%d, %d, %d)\");", text, color.r, color.g, color.b))
end

vgui.Register("ttt_hud_role", {
	Paint = function(self, w, h)
		--[[local ent = self:GetParent():GetTarget()

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

		local other_text = string.FormattedTime(math.max(0, ttt.GetRoundTime() - CurTime()), "%02i:%02i")

		draw.SimpleTextOutlined(
			other_text, "TTTHUDFont", w - border_size * 5, h / 2,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black
		)]]
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

vgui.Register("ttt_crosshairs", {
	Paint = function(self, w, h)
		--[[local ent = self:GetParent():GetTarget()

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

		if (h < 50) then
			draw.SimpleTextOutlined(
				cur_bullets.." + "..extra, "TTTHUDFont", border_size, border_size, color_white,
				TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black
			)
		else
			surface.SetFont "TTTHUDAmmoFontLarge"
			local w1 = surface.GetTextSize(max_bullets)
			surface.SetFont "TTTHUDAmmoFontSmall"
			local w2 = surface.GetTextSize("+"..extra)
			local maxw = math.max(w1, w2)
			draw.SimpleTextOutlined(
				cur_bullets, "TTTHUDAmmoFontLarge", border_size + maxw / 2, border_size, color_white,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black
			)
			draw.SimpleTextOutlined(
				"+"..extra, "TTTHUDAmmoFontSmall", border_size + maxw / 2, h - border_size, color_white,
				TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black
			)
		end]]
	end
})

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

ttt.HUDHealthPanel = vgui.Create("ttt_hud_health", GetHUDPanel())
