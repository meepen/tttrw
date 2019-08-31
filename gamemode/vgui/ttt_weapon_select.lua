
local font_tall = math.Round(ScrH() / 70)
surface.CreateFont("ttt_weapon_select_font", {
	font = 'Lato',
	size = font_tall,
	weight = 100,
	shadow = true
})

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(Color(0xb, 0xc, 0xb, 200))

	self:DockMargin(0, 0, 0, 4)

	self.Label = self:Add "DLabel"
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
	self.Label:SetFont "ttt_weapon_select_font"
end
function PANEL:PerformLayout(w, h)
	self:SetTall(font_tall + 6)
	self:GetParent():SizeToChildren(false, true)
	BaseClass.PerformLayout(self, self:GetSize())
end
function PANEL:SetWeapon(wep)
	self.Label:SetText(weapons.GetStored(wep:GetClass()).PrintName)
end
function PANEL:SetActive(b)
	if (IsValid(self.Active) and not b) then
		self.Active:Remove()
	elseif (not IsValid(self.Active) and b) then
		self.Active = self:Add "DImage"
		self.Active:SetSize(self:GetTall() - 4, self:GetTall() - 4)
		self.Active:SetPos(2, 2)
		self.Active:SetImage "materials/tttrw/heart.png"
	end
end

vgui.Register("ttt_weapon_select_weapon", PANEL, "ttt_curved_panel")

local PANEL = {}
gameevent.Listen "player_spawn"
gameevent.Listen "entity_killed"
function PANEL:Init()
	hook.Add("PlayerBindPress", self, self.PlayerBindPress)
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

function PANEL:PlayerBindPress(ply, bind, pressed)
	if (bind == "invprev" or bind == "invnext") then
		local ordered_weps = LocalPlayer():GetWeapons()
		table.sort(ordered_weps, function(a, b)
			return a:GetSlot() < b:GetSlot()
		end)

		if (#ordered_weps == 0) then
			return
		end

		local index = 1

		for ind, wep in pairs(ordered_weps) do
			if (wep == LocalPlayer():GetActiveWeapon()) then
				index = ind
				break
			end
		end

		if (bind == "invnext") then
			index = index + 1
		else
			index = index - 1
		end

		input.SelectWeapon(ordered_weps[(index - 1) % #ordered_weps + 1])

		return true
	end
end

function PANEL:Think()
	if (not IsValid(LocalPlayer())) then
		return
	end

	if (not LocalPlayer():Alive()) then
		for ind, wep in pairs(self.CachedWeapons) do
			self.OrderedPanels[ind]:Remove()
			table.remove(self.CachedWeapons, ind)
		end
		return
	end

	local wep_lookup = {}
	for _, wep in pairs(LocalPlayer():GetWeapons()) do
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
		pnl:SetZPos(wep:GetSlot())
		pnl:SetWeapon(wep)
		pnl:Dock(TOP)
		table.insert(self.OrderedPanels, pnl)
		table.insert(self.CachedWeapons, wep)
		changed = true
	end

	self:PlayerSwitchWeapon(nil, nil, LocalPlayer():GetActiveWeapon())
end

function PANEL:PerformLayout(w, h)
	self:SetPos(ScrW() - w, ScrH() / 2 - h / 2)
	self:SizeToContents()
end

vgui.Register("ttt_weapon_select", PANEL, "Panel")