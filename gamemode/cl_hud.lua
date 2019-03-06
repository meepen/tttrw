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

function GM:HUDDrawTargetID()
	local ent = GetHUDTarget()

	local tr = ent:GetEyeTrace()

	ent = tr.Entity

	if (IsValid(ent) and ent:IsPlayer()) then

		surface.SetFont "TargetIDSmall"

		local nick = ent:Nick()
		local health = ent:Health()

		surface.SetTextColor(color_black)

		local x, y = ScrW() / 2, ScrH() / 2

		y = y + math.max(50, ScrH() / 20)

		local text = nick
		local tw, th = surface.GetTextSize(text)

		DrawTextShadowed(text, white_text, color_black, x - tw / 2, y, 1, 1)

		local state = ent.HiddenState

		if (IsValid(state) and not state:IsDormant()) then
			y = y + th + 4
			local role = ttt.roles[ent:GetRole()]
			if (role) then
				local col = role.Color
				local txt = role.Name

				tw, th = surface.GetTextSize(txt)

				DrawTextShadowed(txt, col, color_black, x - tw / 2, y, 1, 1)
			end
		end

		local health, maxhealth = ent:Health(), ent:GetMaxHealth()

		local scrw = ScrW()

		local hppct = health / maxhealth
		local wid = math.max(20, scrw / 45)
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


if (IsValid(ttt.HUDPanel)) then
	ttt.HUDPanel:Remove()
end

local hide_when_chat_open = CreateConVar("ttt_hide_hud_when_chat_open", "0", FCVAR_ARCHIVE)


local border_size = 5

vgui.Register("ttt_hud", {
	Init = function(self)
		self.Health = vgui.Create("ttt_hud_health", self)
		self.Health:Dock(TOP)
		self.Health:DockMargin(border_size, border_size, border_size, 0)
		self.Health:SetZPos(1)

		self.Role = vgui.Create("ttt_hud_role", self)
		self.Role:Dock(TOP)
		self.Role:DockMargin(border_size, border_size, border_size, 0)
		self.Role:SetZPos(0)

		self.Role2 = vgui.Create("ttt_hud_role", self)
		self.Role2:Dock(TOP)
		self.Role2:DockMargin(border_size, border_size, border_size, 0)
		self.Role2:SetZPos(0)
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
		print(self:GetPos())

		local children = #self:GetChildren()
		local tall = (h - border_size * (children + 1)) / children
		for _, pnl in ipairs(self:GetChildren()) do
			pnl:SetTall(tall)
		end
		surface.CreateFont("TTTHUDFont", {
			font = "Roboto",
			size = tall - border_size * 2,
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

		hook.Run "HUDDrawTargetID"

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
		local curchange = FrameTime() * 5 -- 500% hp/s
		local change = pct - lastpct
		local curpct = change == 0 and pct or lastpct + (change / math.abs(change)) * math.min(curchange, math.abs(change))

		self.LastPercent = curpct

		surface.SetDrawColor(ColorLerp(health_dead, health_ok, health_full, curpct))
		surface.DrawRect(0, 0, w * curpct, h)


		surface.SetFont "TTTHUDFont"
		local text = string.format("%i HP", ent:Health())
		local tw, th = surface.GetTextSize(text)
		DrawTextShadowed(text, white_text, color_black, w / 2 - tw / 2, h / 2 - th / 2, 2, 2)
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
		local tw, th = surface.GetTextSize(text)

		local x, y = border_size * 5, h / 2 - th / 2
		DrawTextShadowed(text, white_text, color_black, x, y, 2, 2)

		local other_text = string.FormattedTime(math.max(0, ttt.GetRoundTime() - CurTime()), "%02i:%02i")
		tw, th = surface.GetTextSize(other_text)

		local x, y = w - tw - border_size * 5, h / 2 - th / 2
		DrawTextShadowed(other_text, white_text, color_black, x, y, 2, 2)
	end
})

local hide = {
	CHudHealth = true
}

hook.Add("HUDShouldDraw", "TTTHud", function(name)
	if (hide[name]) then
		return false
	end
end)

ttt.HUDPanel = vgui.Create("ttt_hud", GetHUDPanel())