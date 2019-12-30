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
	surface.CreateFont("ttt_radar_font", {font = "Lato", size = 13, weight = 900})
	surface.CreateFont("ttt_radar_num_font", {font = "Roboto", size = 16, weight = 900})

	function ENT:DrawTarget(pl)
		local scrpos = pl.Pos:ToScreen() -- sweet
		local sz = IsOffScreen(scrpos) and 12 or 24
		scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
		scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
		if (IsOffScreen(scrpos)) then return end

		local text = math.ceil(LocalPlayer():GetPos():Distance(pl.Pos))
		surface.SetFont "ttt_radar_num_font"
		local w, h = surface.GetTextSize(text)
		-- Show range to target

		local mult = surface.GetAlphaMultiplier()
		local dist = Vector(ScrW() / 2, ScrH() / 2):Distance(Vector(scrpos.x, scrpos.y)) / math.sqrt(ScrW() * ScrH()) * 1500
		if (dist < 400) then
			surface.SetAlphaMultiplier(0.1 + 0.5 * dist / 400)
		else
			print(dist)
			surface.SetAlphaMultiplier(1)
		end

		draw.SimpleTextOutlined(text, "ttt_radar_num_font", scrpos.x, scrpos.y, white_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0, 255))

		surface.SetDrawColor(pl.Color)

		surface.DrawOutlinedRect(scrpos.x - w / 2 - 5, scrpos.y - h / 2 - 5, w + 10, h + 10)
		surface.DrawOutlinedRect(scrpos.x - w / 2 - 6, scrpos.y - h / 2 - 6, w + 12, h + 12)
		surface.SetAlphaMultiplier(mult)
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
		
		if (self:GetNW2Float("next_scan") != self.NextScan) then
			self:GetTargets()
		end
		
		-- Player radar
		surface.SetTexture(indicator)
		
		for _, pl in pairs(self.Targets) do
			local scrpos = pl.Pos:ToScreen()
			if (not scrpos.visible) then continue end
			
			surface.SetDrawColor(pl.Color)

			self:DrawTarget(pl)
		end

		
		-- Time until next scan
		surface.SetFont "ttt_radar_font"
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

			local mn, mx = pl:GetModelBounds()
			
			self:SetNW2Vector("scan_pos_" .. i, pl:GetPos() + Vector(0, 0, (mx.z + mn.z) / 2))
			
			local color = pl.HiddenState:IsVisibleTo(self:GetParent()) and pl:GetRoleData().Color or ttt.teams.innocent.Color
			
			self:SetNW2Vector("scan_color_" .. i, color:ToVector())
		end
		
		self:SetNW2Int("amount", i)
	end
end
