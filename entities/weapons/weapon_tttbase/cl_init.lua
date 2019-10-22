include "shared.lua"

local ttt_lowered = CreateConVar("ttt_ironsights_lowered", "1", FCVAR_ARCHIVE)

SWEP.DrawCrosshair = true
SWEP.ScopeArcTexture = Material "sprites/scope_arc"

function SWEP:DrawHUD()
	if (self:GetIronsights() and self.HasScope) then
		-- scope arc
		surface.SetMaterial(self.ScopeArcTexture)
		local x = ScrW() / 2


		local is_ironsights = self.CurIronsights
		local toggletime = self.IronTime or 0
		local time = is_ironsights and self.Ironsights.TimeTo or self.Ironsights.TimeFrom
	
		local frac = math.min(1, (self:GetUnpredictedTime() - toggletime) / time)

		surface.SetDrawColor(0, 0, 0, 255)

		-- top right
		surface.DrawTexturedRectUV(x, 0, ScrH() / 2, ScrH() / 2, 0, 1, 1, 0)

		-- top left
		surface.DrawTexturedRectUV(x - ScrH() / 2, 0, ScrH() / 2, ScrH() / 2, 1, 1, 0, 0)

		-- bottom left
		surface.DrawTexturedRectUV(x - ScrH() / 2, ScrH() / 2, ScrH() / 2, ScrH() / 2, 1, 0, 0, 1)
		-- bottom right
		surface.DrawTexturedRect(x, ScrH() / 2, ScrH() / 2, ScrH() / 2)

		surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
		surface.DrawRect(math.floor(x + ScrH() / 2), 0, math.ceil(x - ScrH() / 2), ScrH())
	end
end

function SWEP:DoDrawCrosshair(x, y)
	if (self:GetIronsights() and self.HasScope) then
		local w, h = ScrW(), ScrH()
		surface.SetDrawColor(0, 0, 0, 255)

		surface.DrawLine(x - w / 2, y, x + w / 2, y)
		surface.DrawLine(x, y - h / 2, x, y + h / 2)

		surface.SetDrawColor(255, 255, 255, 255)

		surface.DrawRect(x - 1, y - 1, 3, 3)

		return true
	end
	
	ttt.DefaultCrosshair(x, y)

	return true
end

function SWEP:OverrideCommand(ply, cmd)
	if (self:GetOwner() ~= ply or ply:GetActiveWeapon() ~= self) then
		return
	end
	local ang = cmd:GetViewAngles()
	ang.r = 0

	if (self.HitboxHit and cmd:CommandNumber() ~= 0) then
		ang.r = math.Clamp(math.Round(self.HitboxHit), 0, 10) + self.EntityHit:EntIndex() * 11
		self.HitboxHit = nil
		self.EntityHit = nil
	end

	cmd:SetViewAngles(ang)
end

local server, client = Color(20,20,255,0), Color(255,20,20,0)
local lifetime = 0.5

net.Receive("tttrw_developer_hitboxes", function(len, pl)
	local tick = net.ReadUInt(32)

	local wep = net.ReadEntity()
	
	local cl = wep.DeveloperInformations

	if (not cl or cl.Tick ~= tick) then
		return
	end

	local hitboxes = {}
	pl = LocalPlayer()

	for i = 1, net.ReadUInt(16) do
		local pos, min, max, angle = net.ReadVector(), net.ReadVector(), net.ReadVector(), net.ReadAngle()
		hitboxes[i] = {pos, min, max, angle}

		local name = pl:GetBoneName(pl:GetHitBoxBone(i - 1, pl:GetHitboxSet()))

		if (name == "ValveBiped.Bip01_L_Foot" and pos:Distance(cl.hitboxes[i][1]) <= 10) then
			return
		end
	
	end

	for i = 1, #hitboxes do
		local hitbox = hitboxes[i]
		debugoverlay.BoxAngles(hitbox[1], hitbox[2], hitbox[3], hitbox[4], lifetime, server)

		hitbox = cl.hitboxes[i]
		debugoverlay.BoxAngles(hitbox[1], hitbox[2], hitbox[3], hitbox[4], lifetime, client)
	end

	--[[
	local otherstuff = net.ReadTable()

	printf("TIME\n    SV - %.4f\n    CL - %.4f", otherstuff.CurTime, cl.otherstuff.CurTime)
	for ply, data in pairs(otherstuff) do
		if (type(ply) == "string") then
			continue
		end

		printf("%s", ply:Nick())
		printf("    SV - Velocity(%.2f %.2f %.2f) Sequence(%s) EyeAngles(%.2f %.2f %.2f) Angles(%.2f %.2f %.2f) Position(%.2f %.2f %.2f) Cycle(%.2f)", data.Velocity.x, data.Velocity.y, data.Velocity.z, ply:GetSequenceActivityName(data.Sequence), data.EyeAngles.p, data.EyeAngles.y, data.EyeAngles.r, data.Angles.p, data.Angles.y, data.Angles.r, data.Pos.x, data.Pos.y, data.Pos.z, data.Cycle)
		printf("         m_bJumping(%s) m_fGroundTime(%.2f) m_bFirstJumpFrame(%s) m_flJumpStartTime(%.2f) OnGround(%s)", data.m_bJumping, data.m_fGroundTime or -1, data.m_bFirstJumpFrame, data.m_flJumpStartTime, not not data.OnGround)
		data = cl.otherstuff[ply]
		printf("    CL - Velocity(%.2f %.2f %.2f) Sequence(%s) EyeAngles(%.2f %.2f %.2f) Angles(%.2f %.2f %.2f) Position(%.2f %.2f %.2f) Cycle(%.2f)", data.Velocity.x, data.Velocity.y, data.Velocity.z, ply:GetSequenceActivityName(data.Sequence), data.EyeAngles.p, data.EyeAngles.y, data.EyeAngles.r, data.Angles.p, data.Angles.y, data.Angles.r, data.Pos.x, data.Pos.y, data.Pos.z, data.Cycle)
		printf("         m_bJumping(%s) m_fGroundTime(%.2f) m_bFirstJumpFrame(%s) m_flJumpStartTime(%.2f) OnGround(%s)", data.m_bJumping, data.m_fGroundTime or -1, data.m_bFirstJumpFrame, data.m_flJumpStartTime, not not data.OnGround)
	end
	]]
end)

local host_timescale = GetConVar("host_timescale")

function SWEP:GetUnpredictedTime()
	return (self.CurTime or 0) + (RealTime() - (self.RealTime or 0)) * game.GetTimeScale() * host_timescale:GetFloat()
end

local vector_lower = Vector(0, 0, 2)

function SWEP:GetViewModelPosition(pos, ang)
	if (not self.Ironsights or self.CurIronsights == nil) then
		return
	end

	local is_ironsights = self.CurIronsights
	local toggletime = self.IronTime or 0
	local time = is_ironsights and self.Ironsights.TimeTo or self.Ironsights.TimeFrom

	local frac = math.min(1, (self:GetUnpredictedTime() - toggletime) / time)

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

	if (IsValid(self:GetOwner()) and self:GetOwner():Alive()) then
		ang = ang - self:GetOwner():GetViewPunchAngles()
	end

	return pos, ang + self:GetCurrentUnpredictedViewPunch()
end

function SWEP:GetCurrentUnpredictedFOVMultiplier()
	local fov, time, duration = self.FOVMultiplier or 1, self.FOVMultiplierTime or -0.1, self.FOVMultiplierDuration or 0.1
	local ofov = self.OldFOVMultiplier or 1

	local cur = math.min(1, (self:GetUnpredictedTime() - time) / duration)

	local res = ofov + (fov - ofov) * cur ^ 0.5

	if (self:GetOwner() ~= LocalPlayer()) then
		return math.sqrt(res)
	end

	return res
end

function SWEP:TranslateFOV(fov)
	return fov * self:GetCurrentUnpredictedFOVMultiplier()
end

local quat_zero = Quaternion()

function SWEP:GetCurrentUnpredictedViewPunch()
	local delay = self.Primary.RecoilTiming or self.Primary.Delay
	local time = self._ViewPunchTime or -math.huge
	local frac = (self:GetUnpredictedTime() - time) / delay
	
	if (frac >= 1) then
		return angle_zero
	end

	local vp = self._ViewPunch or angle_zero
	local diff = Quaternion():SetEuler(-vp):Slerp(quat_zero, frac):ToEulerAngles()

	return diff
end

function SWEP:CalcView(ply, pos, ang, fov)
	local delay = self.Primary.Delay * 2

	return pos, ang + self:GetCurrentUnpredictedViewPunch() - ply:GetViewPunchAngles(), fov
end

function SWEP:CalcViewPunch()
	self._ViewPunch = self:GetViewPunch()
	self._ViewPunchTime = self:GetViewPunchTime()
end

function SWEP:CalcFOV()
	self.FOVMultiplier = self:GetFOVMultiplier()
	self.FOVMultiplierTime = self:GetFOVMultiplierTime()
	self.FOVMultiplierDuration = self:GetFOVMultiplierDuration()
	self.OldFOVMultiplier = self:GetOldFOVMultiplier()
end

function SWEP:CalcUnpredictedTimings()
	self.CurTime = CurTime()
	self.RealTime = RealTime()
end

function SWEP:CalcViewModel()
	self.CurIronsights = self:GetIronsights()
	self.IronTime = self:GetIronsightsTime()
end

function SWEP:CalcAllUnpredicted(force)
	if (not IsFirstTimePredicted() or force) then
		return
	end

	self:CalcUnpredictedTimings()
	self:CalcViewPunch()
	self:CalcViewModel()
	self:CalcFOV()
end

concommand.Remove "gmod_undo"