SWEP.Author = "Meepen"
SWEP.Instructions = "Use this as a base weapon."
SWEP.Slot = 1
SWEP.SlotPos = 0

DEFINE_BASECLASS "weapon_base"

SWEP.Primary.Automatic   = true
SWEP.Primary.Delay       = 0.1
SWEP.Primary.DefaultClip = 100000
SWEP.Primary.ClipSize    = 32
SWEP.Primary.Damage      = 20

SWEP.HeadshotMultiplier  = 2

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0, 0, 0)
}

SWEP.Ironsights = {
	Pos = Vector(-8, 4, 3.9),
	Angle = Vector(0, 0, 1.5),
	TimeTo = 0.01,
	TimeFrom = 2,
	Editing
}

SWEP.PredictableSpread = true

function SWEP:NetworkVarNotifyCallback(name, old, new)
	printf("%s::%s %s -> %s", self:GetClass(), name, old, new)
end

function SWEP:NetVar(name, type, default, notify)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)
	if (default) then
		self["Set"..name](self, default)
	end

	if (notify) then
		self:NetworkVarNotify(name, self.NetworkVarNotifyCallback)
	end
end

local scales = {
	[HITGROUP_LEFTARM] = 0.7,
	[HITGROUP_RIGHTARM] = 0.7,
	[HITGROUP_LEFTLEG] = 0.7,
	[HITGROUP_RIGHTLEG] = 0.7,
	[HITGROUP_GEAR] = 0.7
}
function SWEP:ScaleDamage(hitgroup, dmg)
	-- More damage if we're shot in the head
	if (hitgroup == HITGROUP_HEAD) then
		dmg:ScaleDamage(self.HeadshotMultiplier)
	end

	-- Less damage if we're shot in the arms or legs
	if (scales[hitgroup]) then
		dmg:ScaleDamage(scales[hitgroup])
	end
end

function SWEP:SetupDataTables()
	self:NetVar("Ironsights", "Bool", false)
	self:NetVar("IronsightsTime", "Float", 0)
	self:NetVar("FOVMultiplier", "Float", 1)
	self:NetVar("OldFOVMultiplier", "Float", 1)
	self:NetVar("FOVMultiplierTime", "Float", -0.1)
	self:NetVar("FOVMultiplierDuration", "Float", 0.1)
	self:NetVar("ViewPunch", "Angle", angle_zero)
	self:NetVar("ViewPunchTime", "Float", -math.huge)
	self:NetVar("RealLastShootTime", "Float", -math.huge)
	self:NetVar("ConsecutiveShots", "Int", 0)
	hook.Run("TTTInitWeaponNetVars", self)
end

function SWEP:Initialize()
	if (self.Primary and self.Primary.Ammo == "Buckshot" and not self.PredictableSpread) then
		printf("Warning: %s weapon type has shotgun ammo and no predictable spread", self:GetClass())
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:ChangeIronsights(on)
	if (not self.Ironsights) then
		return
	end

	if (self:GetIronsights() == on) then
		return
	end

	self:SetIronsights(not self:GetIronsights())

	local old, new
	if (self:GetIronsights()) then
		old, new = self.Ironsights.TimeFrom, self.Ironsights.TimeTo
	else
		new, old = self.Ironsights.TimeFrom, self.Ironsights.TimeTo
	end

	local frac = math.min(1, (CurTime() - self:GetIronsightsTime()) / old) * new

	self:SetIronsightsTime(CurTime() - new + frac)
	self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), CurTime() + new))

	if (CLIENT and IsFirstTimePredicted()) then
		self:CalcViewModel()
	end

	self:DoZoom(self:GetIronsights())
end

function SWEP:DoZoom(state)
	if (not self.Ironsights) then
		return
	end

	if (state) then
		self:ChangeFOVMultiplier(self.Ironsights.Zoom, self.Ironsights.TimeTo)
	elseif (self.HasScope) then
		self:ChangeFOVMultiplier(1, 0)
	else
		self:ChangeFOVMultiplier(1, self.Ironsights.TimeFrom)
	end
end

function SWEP:Reload()
	self:ChangeIronsights(false)
	if (CLIENT) then
		self:CalcFOV()
	end
	BaseClass.Reload(self)
end

function SWEP:SecondaryAttack()
	self:ChangeIronsights(true)
end

function SWEP:GetDeveloperMode()
	return true
end

local informations = {}

function SWEP:OnDrop()
	self:SetIronsightsTime(CurTime() - self.Ironsights.TimeFrom)
	self:SetIronsights(false)
	self:DoZoom(false)
end

function SWEP:FireBulletsCallback(tr, dmginfo)
	local bullet = dmginfo:GetInflictor().Bullets
	local distance = tr.HitPos:Distance(tr.StartPos)
	if (distance > bullet.DamageDropoffRange) then
		local pct = math.min(1, (distance - bullet.DamageDropoffRange) / (bullet.DamageDropoffRangeMax - bullet.DamageDropoffRange))
		dmginfo:ScaleDamage(1 - pct * (1 - bullet.DamageMinimumPercent))
	end
end

local vector_origin = vector_origin

function SWEP:ShootBullet(bullet_info)
	local owner = self:GetOwner()

	if (self:GetDeveloperMode()) then
		owner:LagCompensation(true)
		local tick = math.floor(CurTime() / engine.TickInterval())
		local hitboxes = {}
		for _, ply in pairs(player.GetAll()) do
			ply:SetupBones()
			for group = 0, ply:GetHitBoxGroupCount() - 1 do 
				for hitbox = 0, ply:GetHitBoxCount(group) - 1 do
					local bone = ply:GetHitBoxBone(hitbox, group)
					local pos, angles = ply:GetBonePosition(bone)
					local min, max = ply:GetHitBoxBounds(hitbox, group)
					hitboxes[#hitboxes + 1] = {
						mins = min,
						maxs = max,
						pos = pos,
						angles = angles
					}
				end
			end
		end
		owner:LagCompensation(false)

		if (SERVER) then
			net.Start "tttrw_developer_hitboxes"
				net.WriteUInt(tick, 32)
				net.WriteEntity(self)
				--net.WriteEntity(game.Get)
				--net.WriteVector(tr.HitPos)
				--net.WriteVector(tr.StartPos)
				net.WriteTable(hitboxes)
			net.Send(self:GetOwner())
		else
			self.DeveloperInformations = {
				Tick = tick,
				--Entity = tr.Entity,
				--HitPos = tr.HitPos,
				--StartPos = tr.StartPos,
				hitboxes = hitboxes
			}
		end
	end

	local bullet_ang = owner:EyeAngles() + owner:GetViewPunchAngles()

	local bullet_info = self.Bullets

	local bullet = {
		Num = bullet_info.Num,
		Attacker = owner,
		Damage = self.Primary.Damage,
		Tracer = bullet_info.Tracer or 1,
		TracerName = bullet_info.TracerName,
		Spread = self:GetSpread(),
		Callback = function(_, ...)
			if (IsValid(self)) then
				self:FireBulletsCallback(...)
			end
		end,
		Src = owner:GetShootPos(),
		Dir = bullet_ang:Forward()
	}

	self:SetRealLastShootTime(CurTime())
	owner:LagCompensation(true)
	self:FireBullets(bullet)
	owner:LagCompensation(false)

	self:ShootEffects()
end

function SWEP:GetSpread()
	return self.Bullets.Spread * (0.25 + (-self:GetMultiplier() + 2) * 0.75)
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) then
		return
	end

	local interval = engine.TickInterval()
	local delay = math.ceil(self.Primary.Delay / interval) * interval
	local diff = (CurTime() - self:GetRealLastShootTime()) / delay

	if (diff <= 1.25) then
		self:SetConsecutiveShots(self:GetConsecutiveShots() + 1)
	else
		self:SetConsecutiveShots(0)
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:ShootBullet(150, 1, 0.01)

	self:TakePrimaryAmmo(1)

	self:ViewPunch()
end

local quat_zero = Quaternion()

function SWEP:GetCurrentViewPunch()
	local delay = self.Primary.RecoilTiming or self.Primary.Delay
	local time = self:GetViewPunchTime()
	local frac = (CurTime() - time) / delay
	
	if (frac >= 1) then
		return angle_zero
	end

	local vp = self:GetViewPunch()
	local diff = Quaternion():SetEuler(-vp):Slerp(quat_zero, frac):ToEulerAngles()

	return diff
end

function SWEP:ViewPunch()
	local vp = self:GetViewPunchAngles()
	self:SetViewPunch(vp)
	self:SetViewPunchTime(CurTime())

	if (not CLIENT or not IsFirstTimePredicted()) then
		return
	end

	local own = self:GetOwner()
	own:SetEyeAngles(own:EyeAngles() + vp)

	self:CalcViewPunch()
end

function SWEP:Think()
	if (self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2)) then
		self:ChangeIronsights(false)
	end

	if (CLIENT) then
		self:CalcAllUnpredicted()
	end
end

function SWEP:GetCurrentFOVMultiplier()
	local fov, time, duration = self:GetFOVMultiplier(), self:GetFOVMultiplierTime(), self:GetFOVMultiplierDuration()
	local ofov = self:GetOldFOVMultiplier()

	local cur = math.min(1, (CurTime() - time) / duration)

	return ofov + (fov - ofov) * cur
end

function SWEP:ChangeFOVMultiplier(fovmult, duration)
	self:SetOldFOVMultiplier(self:GetCurrentFOVMultiplier())
	self:SetFOVMultiplier(fovmult)
	self:SetFOVMultiplierDuration(duration)
	self:SetFOVMultiplierTime(CurTime())
end

function SWEP:GetMultiplier()
	return 1 + math.max(0, 1 - self:GetConsecutiveShots() / 4)
end

function SWEP:GetZoomMultiplier()
	return self:GetIronsights() and self.Ironsights.Zoom ^ 0.7 or 1
end

function SWEP:GetViewPunchAngles()
	return Angle(-self.Primary.Recoil * self:GetMultiplier() * self:GetZoomMultiplier(), 0, 0)
end

function SWEP:AdjustMouseSensitivity()
	if (self:GetIronsights()) then
		return self.Ironsights.Zoom
	end
end