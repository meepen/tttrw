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

function SWEP:ScaleDamage(hitgroup, dmg)
	-- More damage if we're shot in the head
	if (hitgroup == HITGROUP_HEAD) then
		dmg:ScaleDamage(self.HeadshotMultiplier)
	end

	-- Less damage if we're shot in the arms or legs
	if (hitgroup == HITGROUP_LEFTARM or
		hitgroup == HITGROUP_RIGHTARM or
		hitgroup == HITGROUP_LEFTLEG or
		hitgroup == HITGROUP_RIGHTLEG or
		hitgroup == HITGROUP_GEAR) then

		dmg:ScaleDamage(0.6)
	end
end

function SWEP:SetupDataTables()
	self:NetVar("Ironsights", "Bool", false, false)
	self:NetVar("IronsightsTime", "Float", 0, false)
	self:NetVar("FOVMultiplier", "Float", 1, false)
	self:NetVar("OldFOVMultiplier", "Float", 1, false)
	self:NetVar("FOVMultiplierTime", "Float", -0.1, false)
	self:NetVar("FOVMultiplierDuration", "Float", 0.1, false)
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
	self:SetNextPrimaryFire(CurTime() + new)

	if (CLIENT) then
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
	return false
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

hook.Add("StartCommand", "developer", function(pl, cmd)
	if (pl:IsBot()) then
		swap = not swap
		--cmd:SetViewAngles(Angle(89, swap and 0 or 180, 0))
	end
end)

local vector_origin = vector_origin

function SWEP:ShootBullet(bullet_info)
	local owner = self:GetOwner()

	if (self:GetDeveloperMode()) then
		owner:LagCompensation(true)
		local tick = math.floor(CurTime() / engine.TickInterval())
		local hitboxes = {}
		for _, ply in pairs(player.GetAll()) do
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
		Tracer = bullet_info.Tracer,
		TracerName = bullet_info.TracerName,
		Spread = bullet_info.Spread,
		Callback = function(_, ...)
			if (IsValid(self)) then
				self:FireBulletsCallback(...)
			end
		end,
		Src = owner:GetShootPos(),
		Dir = bullet_ang:Forward()
	}

	--owner:LagCompensation(true)
	self:FireBullets(bullet)
	--owner:LagCompensation(false)

	self:ShootEffects()
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) then
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)

	self:ShootBullet(150, 1, 0.01)

	self:TakePrimaryAmmo(1)

	self.Owner:ViewPunch(Angle(-1, 0, 0))
end

function SWEP:Think()
	if (self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2)) then
		self:ChangeIronsights(false)
	end

	if (CLIENT) then
		self:CalcViewModel()
		self:CalcFOV()
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