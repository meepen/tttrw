local function Player()
	return ttt.GetHUDTarget()
end

local PANEL = {}

function PANEL:Init()
	self:DockMargin(0, 0, 0, 4)
	self.NumberContainer = self:Add "ttt_curved_panel"
	self.NumberContainer:Dock(RIGHT)
	self.NumberContainer:SetColor(Color(0, 0, 0))
	self.Seperator = self:Add "ttt_curved_panel"
	self.Seperator:Dock(RIGHT)
	self.Seperator:SetColor(Color(0, 0, 0, 0))
	self.Seperator:SetWide(0)
	self.Number = self.NumberContainer:Add "tttrw_label"
	self.Number:Dock(LEFT)

	self.WeaponText = self:Add "tttrw_label"
	self.WeaponText:Dock(RIGHT)
	self.WeaponText:SetWide(0)
	self.WeaponText:SetContentAlignment(5)
	self.WeaponText:DockMargin(0, 2, 8, 2)
	self.WeaponText:SetFont(ttt.hud.fonts["$$weaponselect.weapon"] or "DermaDefault")

	self.Number:SetFont(ttt.hud.fonts["$$weaponselect.number"] or "DermaDefault")
	self.Number:SetContentAlignment(5)
end

function PANEL:SetData(slot, wep)
	self.Weapon = wep
	self.Slot = slot

	self.Number:SetText(slot + 1)
	self.Number:SizeToContentsX(16)
	self.NumberContainer:InvalidateLayout(true)
	self.NumberContainer:SizeToChildren(true, false)

	-- instantly update as necessary
	self:Think()
end

function PANEL:OnTextWidthAcquired(width)
end

function PANEL:Think()
	local wep = self.Weapon
	if (not IsValid(wep)) then
		return
	end

	local col = Color(0, 0, 0)
	if (IsValid(Player()) and Player():GetActiveWeapon() == self.Weapon) then
		col = self:GetColor()
	end
	self.NumberContainer:SetColor(col)

	local txt = (wep:GetPrintName() or ""):Trim()
	if (txt ~= self.WeaponText:GetText()) then
		self.WeaponText:SetText(txt)
		self.WeaponText:SizeToContentsX()

		self:InvalidateLayout(true)
		self:OnTextWidthAcquired(self.WeaponText:GetWide() + self.NumberContainer:GetWide() + 16)
	end
end

function PANEL:GetColor()
	if (not IsValid(self.Weapon) or not self.Weapon.GetPrintNameColor) then
		return Color(0, 0, 0)
	end

	local alpha = 64

	if (IsValid(Player()) and Player():GetActiveWeapon() == self.Weapon) then
		alpha = 128
	end

	return ColorAlpha(self.Weapon:GetPrintNameColor(), alpha)
end

local gradient = Material "gui/gradient.png"

function PANEL:Paint(w, h)
	local mul = 1
	if (self.Fades) then
		local start, ends = self.Fades[1], self.Fades[2]
		local t = CurTime()
		if (t >= ends) then
			mul = 0
		elseif (t >= start) then
			mul = 1 - (t - start) / (ends - start)
		end
	end

	self.WeaponText:SetAlpha(mul * 255)

	gradient:SetVector("$color", self:GetColor():ToVector())
	gradient:SetFloat("$alpha", self:GetColor().a / 255 * mul)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRectUV(0, 0, self.Seperator:GetPos(), h, 1, 0, 0, 1)
end

function PANEL:FadeOut(start, ends)
	self.Fades = {start, ends}
end

vgui.Register("ttt_weapon_select_weapon", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetSize(0, 0)
	self.StoredSlots = {}
	self.StoredPanels = {}
end

function PANEL:NotifyInput()
	self.LastInput = CurTime()
	
	for _, child in pairs(self:GetChildren()) do
		child:FadeOut(self.LastInput + 2, self.LastInput + 5)
	end
end

function PANEL:Think()
	local p = Player()
	if (not IsValid(p)) then
		for slot in pairs(self.StoredSlots) do
			self:RemoveSlot(slot)
		end
		return
	end

	if (p ~= self.LastPlayer) then
		self:NotifyInput()
		self.LastPlayer = p
	end

	local wep = p:GetActiveWeapon()

	if (wep ~= self.LastWeapon) then
		self:NotifyInput()
		self.LastWeapon = wep
	end

	local have = {}
	for _, wep in pairs(p:GetWeapons()) do
		local slot = wep:GetSlot()
		if (self.StoredSlots[slot] ~= wep) then
			self:UpdateSlot(slot, wep)
		end
		have[slot] = wep
	end

	for slot, wep in pairs(self.StoredSlots) do
		if (have[slot] ~= wep) then
			self:RemoveSlot(slot)
		end
	end
end

function PANEL:SetWidth()
	local max = 100
	for _, p in pairs(self.StoredPanels) do
		if (IsValid(p)) then
			max = math.max(p.Width or 0, max)
		end
	end

	local cur_width = self:GetWide()
	local new_width = max + 20
	self:SetWide(new_width)
	if ((self.ContentAlignment % 3) == 0) then
		local x, y = self:GetPos()
		self:SetPos(x + cur_width - new_width, y)
	end
end

function PANEL:UpdateSlot(slot, wep)
	self.StoredSlots[slot] = wep
	local p = self.StoredPanels[slot]
	if (not IsValid(p)) then
		p = self:Add "ttt_weapon_select_weapon"
		p:Dock(TOP)
		p:SetZPos(slot)
		self.StoredPanels[slot] = p

		function p.OnTextWidthAcquired(s, w)
			s.Width = w
			self:SetWidth()
		end
		if (self.ContentAlignment >= 4 and self.ContentAlignment <= 6) then
			local x, y = self:GetPos()
			self:SetPos(x, y - p:GetTall() / 2)
		end
	end
	p:SetData(slot, wep)
	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)
	self:NotifyInput()
end

function PANEL:RemoveSlot(slot)
	self.StoredSlots[slot] = nil

	local p = self.StoredPanels[slot]
	if (IsValid(p)) then
		if (self.ContentAlignment >= 4 and self.ContentAlignment <= 6) then
			local x, y = self:GetPos()
			self:SetPos(x, y + p:GetTall() / 2)
		end
		p:Remove()
	end
	self:InvalidateLayout(true)
	self:SizeToChildren(false, true)

	self:SetWidth()
	self:NotifyInput()
end


vgui.Register("ttt_weapon_select", PANEL, "EditablePanel")

local INPUTS = {}

function INPUTS:SetContentalignment(txt)
	self.ContentAlignment = txt
end

ttt.hud.registerelement("weaponselect", INPUTS, "base", "ttt_weapon_select")