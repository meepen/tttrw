local tttrw_force_ammo_bar = CreateConVar("tttrw_force_ammo_bar", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "Force TTTRW HUD to use a bar for ammo")

local DrawTextShadowed = hud.DrawTextShadowed

local health_full = Color(0, 0xff, 0x2b)
local health_ok = Color(0xf0, 0xff, 0)
local health_dead = Color(0xff, 0x33, 0)

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


if (IsValid(ttt.HUDPanel)) then
	ttt.HUDPanel:Remove()
end

local hide_when_chat_open = CreateConVar("ttt_hide_hud_when_chat_open", "0", FCVAR_ARCHIVE)


local border_size = 5

vgui.Register("ttt_hud", {
	Init = function(self)
		self.Health = vgui.Create("ttt_hud_health", self)
		self.Health:Dock(TOP)
		self.Health:SetZPos(1)

		self.Role = vgui.Create("ttt_hud_ammo", self)
		self.Role:Dock(TOP)
		self.Role:SetZPos(0)

		self.Role2 = vgui.Create("ttt_hud_role", self)
		self.Role2:Dock(TOP)
		self.Role2:SetZPos(-1)
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
		local cx, cy = chat.GetChatBoxPos()
		local cw, ch = chat.GetChatBoxSize()
		self:SetSize(scrw / 5, scrh - (cy + ch) - cx)
		self:SetPos(cx, cy + ch)

		border_size = self:GetTall() < 86 and 3 or 5
		

		self.Health:DockMargin(border_size, border_size, border_size, 0)
		self.Role2:DockMargin(border_size, border_size, border_size, 0)
		self.Role:DockMargin(border_size, border_size, border_size, 0)

		local children = #self:GetChildren()
		local tall = math.floor((h - border_size * (children + 1)) / children)
		for _, pnl in ipairs(self:GetChildren()) do
			pnl:SetTall(tall)
		end

		-- 2 is always better looking
		local font_size = math.floor((tall - border_size * 2) / 2) * 2

		surface.CreateFont("TTTHUDFont", {
			font = "Roboto",
			size = font_size,
			weight = 800,
			antialias = true,
			shadow = false
		})
		
		surface.CreateFont("TTTHUDAmmoFontLarge", {
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
		})
	end,
	GetTarget = function()
		return GetHUDTarget()
	end,
	Paint = function(self, w, h)
		local ent = GetHUDTarget()

		if (not ent:Alive()) then
			return
		end

		surface.SetDrawColor(Color(0, 0, 0, 200))
		surface.DrawRect(0, 0, w, h)

		-- TODO(meep): role information
	end
}, "EditablePanel")


vgui.Register("ttt_hud_health", {
	Paint = function(self, w, h)
		local ent = self:GetParent():GetTarget()

		if (not ent:Alive()) then
			return
		end

		local health, maxhealth = ent:Health(), ent:GetMaxHealth()
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
		)
	end
})

vgui.Register("ttt_hud_role", {
	Paint = function(self, w, h)
		local ent = self:GetParent():GetTarget()

		if (not ent:Alive()) then
			return
		end

		local text, color

		if (ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
			text = ent:GetRole()

			color = color_black
			if (ttt.roles[text]) then
				color = ttt.roles[text].Color
			end
		else
			text = ttt.Enums.RoundState[ttt.GetRoundState()]
			color = color_black
		end

		surface.SetDrawColor(color)
		surface.DrawRect(0, 0, w, h)

		surface.SetFont "TTTHUDFont"
		
		draw.SimpleTextOutlined(
			text, "TTTHUDFont", border_size * 5, h / 2,
			color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, color_black
		)

		local other_text = string.FormattedTime(math.max(0, ttt.GetRoundTime() - CurTime()), "%02i:%02i")

		draw.SimpleTextOutlined(
			other_text, "TTTHUDFont", w - border_size * 5, h / 2,
			color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, color_black
		)
	end
})

local ammo_color = Color(244, 229, 66)
local ammo_empty_color = Color(20, 20, 20, 200)

vgui.Register("ttt_hud_ammo", {
	Paint = function(self, w, h)
		local ent = self:GetParent():GetTarget()

		if (not ent:Alive()) then
			return
		end

		local wep = ent:GetActiveWeapon()

		if (not IsValid(wep)) then
			return
		end

		local max_bullets = wep.Primary.ClipSize
		local cur_bullets = wep:Clip1()

		local extra = ent:GetAmmoCount(wep:GetPrimaryAmmoType())

		local one_xth = 12
		local w_per_bullet = math.floor(w / max_bullets)


		if (w_per_bullet < one_xth or tttrw_force_ammo_bar:GetBool()) then
			surface.SetDrawColor(ammo_color)
			local aw = math.ceil(w * (cur_bullets / max_bullets))

			surface.DrawRect(w - aw, 0, aw, h)

			surface.SetDrawColor(ammo_empty_color)
			surface.DrawRect(0, 0, w - aw, h)
		else
			ammo_area = w_per_bullet * max_bullets
			
			surface.SetDrawColor(ammo_color)
			local i = 0
			for x = w, w - ammo_area + 1, -w_per_bullet do
				if (i == cur_bullets) then
					surface.SetDrawColor(ammo_empty_color)
				end
				surface.DrawRect(x - w_per_bullet * (one_xth - 1) / one_xth, 0, w_per_bullet * (one_xth - 1) / one_xth, h)
				i = i + 1
			end
		end

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
		end
	end
})

local hide = {
	CHudHealth = true,
	CHudDamageIndicator = true
}

hook.Add("HUDShouldDraw", "TTTHud", function(name)
	if (hide[name]) then
		return false
	end
end)

ttt.HUDPanel = vgui.Create("ttt_hud", GetHUDPanel())