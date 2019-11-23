AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Radar"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

ENT.Equipment = {
	Name		   = "Radar",
	Desc 		   = "Pings players' locations, showing them to you.",
	CanBuy	       = {
		traitor = true,
		Detective = true
	},
	Cost 	   	   = 1,
	Limit	       = 1,
	Icon           = "materials/tttrw/equipment/radar.png",
}

ENT.Delay = 12

if (CLIENT) then
	ENT.Targets = {}
	ENT.NextScan = 0
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	
	if (CLIENT) then
		self:RegisterHook("HUDPaint", self.Paint)
	else
		self:RegisterTimer(self.Delay, 0, self.Scan)
		self:Scan()
	end
end

if (CLIENT) then
	surface.CreateFont('TabLarge', {font = 'Lato', size = 13, weight = 900})

	function ENT:DrawTarget(pl, size, offset)
		local scrpos = pl.Pos:ToScreen() -- sweet
		local sz = IsOffScreen(scrpos) and size / 2 or size
		scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
		scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
		if (IsOffScreen(scrpos)) then return end
		
		surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

		-- Drawing full size?
		if (sz == size) then
			local text = math.ceil(LocalPlayer():GetPos():Distance(pl.Pos))
			local w, h = surface.GetTextSize(text)
			-- Show range to target
			surface.SetTextPos(scrpos.x - w / 2, scrpos.y + (offset * sz) - h / 2)
			surface.DrawText(text)
		end
	end
	
	function ENT:GetTargets()
		self.Targets = {}

		self.NextScan = self:GetNW2Float("next_scan")
		local amount = self:GetNW2Int("amount")
		for i = 1, amount do
			local target = {}
			target.Pos = self:GetNW2Vector("scan_pos_" .. i)
			target.Color = self:GetNW2Vector("scan_color_" .. i):ToColor()
			
			table.insert(self.Targets, target)
		end
	end
	
	local indicator = surface.GetTextureID("effects/select_ring")
	local time_color = Color(255, 0, 0, 230)

	function ENT:Paint()
		if (self:IsDormant()) then
			return
		end

		surface.SetFont("HudSelectionText")
		
		if (self:GetNW2Float("next_scan") != self.NextScan) then
			self:GetTargets()
		end
		
		-- Player radar
		surface.SetTexture(indicator)
		
		for _, pl in pairs(self.Targets) do
			local scrpos = pl.Pos:ToScreen()
			if (not scrpos.visible) then continue end
			
			surface.SetDrawColor(pl.Color)
			surface.SetTextColor(pl.Color)

			self:DrawTarget(pl, 24, 0)
		end

		
		-- Time until next scan
		surface.SetFont("TabLarge")
		surface.SetTextColor(time_color)

		local remaining = math.max(0, self.NextScan - CurTime())
		local text = string.format("Radar ready for next scan in: %s", string.FormattedTime(remaining, "%02i:%02i"))
		local w, h = surface.GetTextSize(text)

		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() - 140 - h)
		surface.DrawText(text)
	end
else
	function ENT:Scan()
		self:SetNW2Float("next_scan", CurTime() + self.Delay)
		
		local i = 0
		for _, pl in pairs(player.GetAll()) do
			if (pl == self:GetParent() or not pl:Alive()) then continue end
			
			i = i + 1
			
			self:SetNW2Vector("scan_pos_" .. i, pl:GetPos())
			
			local color = pl.HiddenState:IsVisibleTo(self:GetParent()) and pl:GetRoleData().Color or ttt.teams.innocent.Color
			
			self:SetNW2Vector("scan_color_" .. i, color:ToVector())
		end
		
		self:SetNW2Int("amount", i)
	end
end
