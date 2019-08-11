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

		surface.SetDrawColor(0, 0, 0, frac ^ 0.1 * 255)

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
local tttrw_crosshair_color_r = CreateConVar("tttrw_crosshair_color_r", 232, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_g = CreateConVar("tttrw_crosshair_color_g", 80, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_color_b = CreateConVar("tttrw_crosshair_color_b", 94, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_thickness = CreateConVar("tttrw_crosshair_thickness", 2, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_length = CreateConVar("tttrw_crosshair_length", 7, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_gap = CreateConVar("tttrw_crosshair_gap", 3, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_opacity = CreateConVar("tttrw_crosshair_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_outline_opacity = CreateConVar("tttrw_crosshair_outline_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_size = CreateConVar("tttrw_crosshair_dot_size", 0, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")
local tttrw_crosshair_dot_opacity = CreateConVar("tttrw_crosshair_dot_opacity", 255, {FCVAR_ARCHIVE, FCVAR_UNLOGGED}, "")

local function drawCircle(x, y, radius, seg)
	local cir = {}

	table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
	for i = 0, seg do
		local a = math.rad((i / seg) * -360)
		table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

	surface.DrawPoly(cir)
end

function SWEP:DoDrawCrosshair(x, y)
	if (self:GetIronsights() and self.HasScope) then
		local w, h = ScrW(), ScrH()
		surface.SetDrawColor(0, 0, 0, 255)

		surface.DrawLine(x - w / 2, y, x + w / 2, y)
		surface.DrawLine(x, y - h / 2, x, y + h / 2)

		surface.SetDrawColor(255, 0, 0, 255)

		surface.DrawRect(x - 1, y - 1, 3, 3)

		return true
	end

	local r = tttrw_crosshair_color_r:GetInt()
	local g = tttrw_crosshair_color_g:GetInt()
	local b = tttrw_crosshair_color_b:GetInt()
	local t = tttrw_crosshair_thickness:GetInt()
	local len = tttrw_crosshair_length:GetInt()
	local gap = tttrw_crosshair_gap:GetInt()*2
	local opacity = tttrw_crosshair_opacity:GetInt()
	local oopacity = tttrw_crosshair_outline_opacity:GetInt()
	local dot = tttrw_crosshair_dot_size:GetInt()
	local dopacity = tttrw_crosshair_dot_opacity:GetInt()

	local s = len * 2 + gap
	local startw = x - s / 2
	local starth = y - s / 2
	if (len > 0 and t > 0) then
		surface.SetDrawColor(0, 0, 0, oopacity * 255) -- outlines, counterclockwise
		surface.DrawRect(x - t / 2 - 1, starth - 1, t + 2, len + 2)
		surface.DrawRect(startw - 1 , y- t / 2 - 1, len + 2, t + 2)
		surface.DrawRect(x - t / 2 - 1, starth + s - len - 1, t + 2, len + 2)
		surface.DrawRect(startw + s - len - 1, y - t / 2 - 1, len + 2, t + 2)
		surface.SetDrawColor(r, g, b, opacity) -- crosshairs, counterclockwise
		surface.DrawRect(x - t / 2, starth, t, len)
		surface.DrawRect(startw, y - t / 2, len, t)
		surface.DrawRect(x - t / 2, starth + s - len, t, len)
		surface.DrawRect(startw + s - len, y - t / 2, len, t)
	end

	if (dot > 0) then
		surface.SetDrawColor(0, 0, 0, oopacity * 255)
		draw.NoTexture()
		drawCircle(startw + s / 2, starth + s / 2, dot + 2, 45)
		surface.SetDrawColor(r, g, b, dopacity)
		drawCircle(startw + s / 2, starth + s / 2, dot, 45)
	end

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

	return pos, ang + self:GetCurrentUnpredictedViewPunch(), fov
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

function SWEP:CalcAllUnpredicted()
	if (not IsFirstTimePredicted()) then
		return
	end

	self:CalcUnpredictedTimings()
	self:CalcViewPunch()
	self:CalcViewModel()
	self:CalcFOV()
end