
local font_tall = math.Round(ScrH() / 70)
surface.CreateFont("ttt_weapon_select_font", {
	font = 'Lato',
	size = font_tall,
	weight = 100,
	shadow = true
})
surface.CreateFont("ttt_weapon_select_font_outline", {
	font = 'Lato',
	size = font_tall,
	weight = 100,
	outline = true
})

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
	self:SetColor(Player():GetRoleData().Color)
	self:SetCurve(4)
	self:SetCurveBottomRight(false)
	self:SetCurveTopRight(false)
end
function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == Player()) then
		self:SetColor(ttt.roles[new].Color)
	end
end

vgui.Register("ttt_weapon_select_number", PANEL, "ttt_curved_panel")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
	self:SetCurve(4)
	self:SetColor(Color(0xb, 0xc, 0xb, 200))
	self:SetCurveTopRight(false)
	self:SetCurveBottomRight(false)

	self:DockMargin(0, 0, 0, 4)

	self.Label = self:Add "DLabel"
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
	self.Label:SetFont "ttt_weapon_select_font"

	self.Number = self:Add "ttt_weapon_select_number"
	self.Number:Dock(LEFT)
	self.Number:SetZPos(0)
end
function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == Player() and IsValid(self.Active)) then
		self.Active:SetImageColor(ttt.roles[new].Color)
	end
end
function PANEL:PerformLayout(w, h)
	self:SetTall(font_tall + 6)
	self:GetParent():SizeToChildren(false, true)
	self.Number:SetWide(h + self.Number:GetCurve())
	BaseClass.PerformLayout(self, self:GetSize())
end
function PANEL:SetWeapon(wep)
	local swep_tbl = weapons.GetStored(wep:GetClass())
	self.Label:SetText(swep_tbl.PrintName)
	self.Number.Label:SetText(swep_tbl.Slot + 1)
end
function PANEL:SetActive(b)
	if (IsValid(self.Active) and not b) then
		self.Active:Remove()
	elseif (not IsValid(self.Active) and b) then
		self.Active = self:Add "DImage"
		self.Active:SetSize(self:GetTall() - 4, self:GetTall() - 4)
		self.Active:Dock(LEFT)
		self.Active:DockMargin(6, 2, 2, 2)
		self.Active:SetImage "materials/tttrw/heart.png"
		self.Active:SetImageColor(LocalPlayer():GetRoleData().Color)
		self.Active:SetZPos(1)
	end
end

vgui.Register("ttt_weapon_select_weapon", PANEL, "ttt_curved_panel")

local PANEL = {}
gameevent.Listen "player_spawn"
gameevent.Listen "entity_killed"
function PANEL:Init()
	hook.Add("PlayerSwitchWeapon", self, self.PlayerSwitchWeapon)

	self:SetWide(ScrW() / 6)

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
		pnl:SetZPos(weapons.GetStored(wep:GetClass()).Slot)
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

vgui.Register("ttt_weapon_select", PANEL, "Panel")