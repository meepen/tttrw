
local font_tall = math.max(16, math.Round(ScrH() / 60))
surface.CreateFont("ttt_weapon_select_font", {
	font = "Roboto",
	size = font_tall,
	weight = 1000,
})
surface.CreateFont("ttt_weapon_select_font_outline", {
	font = "Roboto",
	size = font_tall,
	weight = 1000,
})


local WEAPON = FindMetaTable "Weapon"

local function Player()
	return ttt.GetHUDTarget()
end


local PANEL = {}

function PANEL:Init()
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
	self.Label = self:Add "DLabel"
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
	self.Label:SetFont "ttt_weapon_select_font_outline"
	self.Label:SetTextColor(Color(12, 13, 12))
	self:SetColor(LocalPlayer():GetRoleData().Color)
	self:SetCurve(2)
	self:SetCurveBottomRight(false)
	self:SetCurveTopRight(false)
end

function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == Player() and new) then
		self:SetColor((ttt.roles[new] or ttt.roles.Spectator).Color)
	end
end

vgui.Register("ttt_weapon_select_number", PANEL, "ttt_curved_panel")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
	hook.Add("Think", self, self.OnWeaponNameChange)

	self:SetCurve(4)
	self:SetColor(outline)
	self:SetCurveTopRight(false)
	self:SetCurveBottomRight(false)

	self:DockMargin(0, 0, 0, 4)

	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Inner:SetColor(main_color)
	self.Inner:SetZPos(0)

	self.Label = self:Add "EditablePanel"
	self.Label:Dock(FILL)
	self.Label:SetZPos(3)

	self.Label.Paint = function(self, w, h)
		local text = self.Text or ""
		local col = self.TextColor or white_text
		surface.SetFont "ttt_weapon_select_font"
		local tw, th = surface.GetTextSize(text)

		local x, y = w / 2 - tw / 2, h / 2 - th / 2

		for _, code in utf8.codes(text) do
			local chr = utf8.char(code)
			local cw, ch = surface.GetTextSize(chr)

			surface.SetTextColor(Color(0, 0, 0, 255))
			for i = -1, 1 do
				surface.SetTextPos(x + i, y)
				surface.DrawText(chr)
				surface.SetTextPos(x, y + i)
				surface.DrawText(chr)
			end

			surface.SetTextColor(col)
			surface.SetTextPos(x, y)
			surface.DrawText(chr)

			x = x + cw
		end
	end

	self.Number = self:Add "ttt_weapon_select_number"
	self.Number:Dock(LEFT)
	self.Number:SetZPos(1)
end

function PANEL:OnWeaponNameChange()
	if (IsValid(self.Weapon) and self.Weapon.GetPrintName) then
		self.Label.Text = self.Weapon:GetPrintName()
		local col = white_text
		if (self.Weapon.GetPrintNameColor) then
			col = self.Weapon:GetPrintNameColor()
		end
		self.Label.TextColor = col
	end
end

function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == Player() and IsValid(self.Active) and new) then
		self.Active:SetImageColor(ttt.roles[new].Color)
	end
end

function PANEL:PerformLayout(w, h)
	self:SetTall(font_tall + 6)
	self:GetParent():SizeToChildren(false, true)
	self.Number:SetWide(h + self.Number:GetCurve())
end

function PANEL:SetWeapon(wep)
	local swep_tbl = baseclass.Get(wep:GetClass())
	self.Weapon = wep
	self.Label:SetText "lol who knows"
	local swep_tbl = 
	self.Number.Label:SetText(swep_tbl.Slot + 1)
end

function PANEL:SetActive(b)
	if (IsValid(self.Active) and not b) then
		self.Active:Remove()
	elseif (not IsValid(self.Active) and b) then
		self.Active = self.Label:Add "EditablePanel"
		function self.Active:Paint(w, h)
			surface.SetDrawColor(self.Color)
			draw.NoTexture()
			surface.DrawRect(0, 0, w / 2, h)
		end
		function self.Active:SetImageColor(col)
			self.Color = col
		end
		self.Active:SetSize(self:GetTall() - 8, self:GetTall())
		self.Active:Dock(LEFT)
		self.Active:SetImageColor(LocalPlayer():GetRoleData().Color)
		self.Active:SetZPos(1)
	end
end

vgui.Register("ttt_weapon_select_weapon", PANEL, "ttt_curved_panel_outline")

local PANEL = {}
gameevent.Listen "player_spawn"
gameevent.Listen "entity_killed"
function PANEL:Init()
	hook.Add("PlayerSwitchWeapon", self, self.PlayerSwitchWeapon)

	self:SetWide(math.max(ScrW() / 6, 100))

	self.CachedWeapons = {}
	self.OrderedPanels = {}
end

function PANEL:PlayerSwitchWeapon(ply, old, new)
	if (IsValid(self.Active)) then
		self.Active:SetActive(false)
		self.Active = nil
	end

	for k, wep in pairs(self.CachedWeapons) do
		if (wep == new) then
			self.OrderedPanels[k]:SetActive(true)
			self.Active = self.OrderedPanels[k]
		end
	end
end

function PANEL:Think()
	if (not IsValid(Player())) then
		return
	end

	if (not Player():Alive()) then
		for ind, wep in pairs(self.CachedWeapons) do
			self.OrderedPanels[ind]:Remove()
			table.remove(self.CachedWeapons, ind)
			table.remove(self.OrderedPanels, ind)
		end
		return
	end

	local wep_lookup = {}
	for _, wep in pairs(Player():GetWeapons()) do
		wep_lookup[wep] = true
	end

	local changed = false

	for ind, wep in pairs(self.CachedWeapons) do
		if (not wep_lookup[wep]) then
			self.OrderedPanels[ind]:Remove()
			table.remove(self.CachedWeapons, ind)
			table.remove(self.OrderedPanels, ind)
			changed = true
		end
		wep_lookup[wep] = nil
	end

	for wep in pairs(wep_lookup) do
		local pnl = self:Add "ttt_weapon_select_weapon"
		pnl:SetZPos(baseclass.Get(wep:GetClass()).Slot)
		pnl:SetWeapon(wep)
		pnl:Dock(TOP)
		table.insert(self.OrderedPanels, pnl)
		table.insert(self.CachedWeapons, wep)
		changed = true
	end

	self:PlayerSwitchWeapon(nil, nil, Player():GetActiveWeapon())
end

function PANEL:PerformLayout(w, h)
	self:SetPos(ScrW() - w, ScrH() / 2 - h / 2)
	self:SizeToContents()
end

function PANEL:AcceptInput() end

vgui.Register("ttt_weapon_select", PANEL, "Panel")