include "shared.lua"

local ttt_lowered = CreateConVar("ttt_ironsights_lowered", "1", FCVAR_ARCHIVE)

function SWEP:DoDrawCrosshair(x, y)
	if (self:GetIronsights()) then
		--return true
	end
	surface.SetDrawColor(255, 0, 255, 255)
	surface.DrawLine(x - 5, y, x + 6, y)
	surface.DrawLine(x, y - 5, x, y + 6)
	return true
end

local server, client = Color(255,20,20), Color(20,20,255)
local lifetime = 2

net.Receive("tttrw_developer_hitboxes", function(len, pl)
	local tick = net.ReadUInt(32)

	local wep = net.ReadEntity()
	
	local cl = wep.DeveloperInformations

	if (not cl or cl.Tick ~= tick) then
		return
	end

	--local hitply = net.ReadEntity()

	--debugoverlay.Cross(net.ReadVector(), 2, lifetime, color_white, true)
	--debugoverlay.Cross(cl.HitPos, 2, lifetime, color_black, true)

	--debugoverlay.Cross(net.ReadVector(), 2, lifetime, server, true)
	--debugoverlay.Cross(cl.StartPos, 2, lifetime, client, true)

	local hitboxes = net.ReadTable()

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i]
		debugoverlay.BoxAngles(hitbox.pos, hitbox.mins, hitbox.maxs, hitbox.angles, lifetime, server)

		local hitbox = cl.hitboxes[i]
		debugoverlay.BoxAngles(hitbox.pos, hitbox.mins, hitbox.maxs, hitbox.angles, lifetime, client)
	end
end)

function SWEP:CalcViewModel()
	if (not CLIENT) or (not IsFirstTimePredicted()) then return end
	self.CurIronsights = self:GetIronsights()
	self.IronTime = self:GetIronsightsTime()
	self.CurTime = CurTime()
	self.RealTime = RealTime()
end

local vector_lower = Vector(0, 0, 2)
local host_timescale = GetConVar("host_timescale")

function SWEP:GetViewModelPosition(pos, ang)
	if (not self.Ironsights or self.CurIronsights == nil) then
		return
	end

	local is_ironsights = self.CurIronsights
	local toggletime = self.IronTime
	local time = is_ironsights and self.Ironsights.TimeTo or self.Ironsights.TimeFrom

	local frac = math.min(1, (self.CurTime + (RealTime() - self.RealTime) * game.GetTimeScale() * host_timescale:GetFloat() - toggletime) / time)

	local ironpos, ironang = self.Ironsights.Pos - (ttt_lowered:GetBool() and vector_lower or vector_origin), self.Ironsights.Angle

	local frompos, fromang, topos, toang = vector_origin, vector_origin, ironpos, ironang
	if (not is_ironsights) then
		topos, toang, frompos, fromang = frompos, fromang, topos, toang
	end

	local newang = LerpVector(frac, fromang, toang)
	local newpos = LerpVector(frac, frompos, topos)

	ang:RotateAroundAxis(ang:Right(),   newang.x)
	ang:RotateAroundAxis(ang:Up(),      newang.y)
	ang:RotateAroundAxis(ang:Forward(), newang.z)

	pos = pos + newpos.x * ang:Right()
	          + newpos.y * ang:Forward()
			  + newpos.z * ang:Up()


	if (is_ironsights) then
		self.SwayScale = 0.2
		self.BobScale = 0.07
	else
		self.SwayScale = 1
		self.BobScale = 1
	end

	return pos, ang
end
