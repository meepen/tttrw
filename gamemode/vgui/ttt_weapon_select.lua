
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
local PANEL = {}

function PANEL:Init()
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
	self.Label = self:Add "DLabel"
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
	self.Label:SetFont "ttt_weapon_select_font_outline"
	self:SetColor(LocalPlayer():GetRoleData().Color)
	self:SetCurve(4)
	self:SetCurveBottomRight(false)
	self:SetCurveTopRight(false)
end
function PANEL:OnPlayerRoleChange(ply, old, new)
	if (ply == LocalPlayer() and IsValid(self.Active)) then
		self.Active:SetImageColor(ttt.roles[new].Color)
	end
end

vgui.Register("ttt_weapon_select_number", PANEL, "ttt_curved_panel")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	hook.Add("OnPlayerRoleChange", self, self.OnPlayerRoleChange)
	self:SetCurve(4)
	self:SetColor(Color(0xb, 0xc, 0xb, 200))

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
	if (ply == LocalPlayer() and IsValid(self.Active)) then
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
	if (bind:match"^slot%d+$") then
		local num = tonumber(bind:match"^slot(%d+)$") - 1
		local ordered_weps = {}
		for _, wep in pairs(LocalPlayer():GetWeapons()) do
			if (wep:GetSlot() == num) then
				table.insert(ordered_weps, wep)
			end
		end

		if (#ordered_weps == 0) then
			return true
		end

		table.sort(ordered_weps, function(a, b)
			return a:GetSlotPos() < b:GetSlotPos()
		end)

		local index = 1
		for ind, wep in pairs(ordered_weps) do
			if (wep == LocalPlayer():GetActiveWeapon()) then
				index = ind
			end
		end


		input.SelectWeapon(ordered_weps[index % #ordered_weps + 1])
		
		return true
	elseif (bind == "invprev" or bind == "invnext") then
		local ordered_weps = LocalPlayer():GetWeapons()
		table.sort(ordered_weps, function(a, b)
			return a:GetSlot() < b:GetSlot()
		end)

		if (#ordered_weps == 0) then
			return true
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
		elseif (bind == "invprev") then
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
			table.remove(self.OrderedPanels, ind)
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