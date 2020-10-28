AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Body Finder"
ENT.Author = "add___123"
ENT.Contact = "itsmeadd.123@gmail.com"

ENT.Equipment = {
	Name		   = "Body Finder",
	Desc 		   = "Pings body locations, showing them to you.",
	CanBuy	       = {
		Detective = true
	},
	Cost 	   	   = 1,
	Limit	       = 1,
	Icon           = "materials/tttrw/equipment/radar.png",
}

ENT.Delay = 30

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
	local draw_color = Color(128, 21, 0)
	local draw_outline = Color(0, 0, 0)

	function ENT:DrawTarget(body)
		local scrpos = body.Pos:ToScreen()
		local sz = IsOffScreen(scrpos) and 12 or 24
		scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
		scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)
		if (IsOffScreen(scrpos)) then return end

		local text = math.ceil(LocalPlayer():GetPos():Distance(body.Pos))
		surface.SetFont "ttt_radar_num_font"
		local w, h = surface.GetTextSize(text)
		-- Show range to target

		local mult = surface.GetAlphaMultiplier()
		local dist = Vector(ScrW() / 2, ScrH() / 2):Distance(Vector(scrpos.x, scrpos.y)) / math.sqrt(ScrW() * ScrH()) * 1500
		if (dist < 400) then
			surface.SetAlphaMultiplier(0.1 + 0.5 * dist / 400)
		else
			surface.SetAlphaMultiplier(1)
		end

		draw.SimpleTextOutlined(text, "ttt_radar_num_font", scrpos.x, scrpos.y, white_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, draw_outline)

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
		
		for _, body in pairs(self.Targets) do
			local scrpos = body.Pos:ToScreen()
			if (not scrpos.visible) then continue end
			
			surface.SetDrawColor(draw_color)

			self:DrawTarget(body)
		end
		
		-- Time until next scan
		surface.SetFont "ttt_radar_font"
		surface.SetTextColor(time_color)

		local remaining = math.max(0, self.NextScan - CurTime())
		local text = string.format("Body finder ready in: %s", string.FormattedTime(remaining, "%02i:%02i"))
		local w, h = surface.GetTextSize(text)

		surface.SetTextPos(ScrW() / 2 - w / 2, ScrH() - 120 - h)
		surface.DrawText(text)
	end
else
	function ENT:Scan()
		self:SetNW2Float("next_scan", CurTime() + self.Delay)
		
		local i = 0
		for _, body in ipairs(ents.FindByClass("prop_ragdoll")) do
			if (not body:GetNW2Bool("IsPlayerBody", false)) then continue end

			i = i + 1
			
			self:SetNW2Vector("scan_pos_" .. i, body:GetPos())
		end
		
		self:SetNW2Int("amount", i)
	end
end
