SWEP.Author = "Meepen"
SWEP.Instructions = "Use this as a base weapon."
SWEP.Slot = 1
SWEP.SlotPos = 0

DEFINE_BASECLASS "weapon_base"

SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.1
SWEP.Primary.DefaultClip = 100000

SWEP.Bullets = {
	Damage = 20,
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1
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

function SWEP:SetupDataTables()
	hook.Run("TTTInitWeaponNetVars", self)
end

function SWEP:Initialize()
	if (self.Primary and self.Primary.Ammo == "Buckshot" and not self.PredictableSpread) then
		printf("Warning: %s weapon type has shotgun ammo and no predictable spread", self:GetClass())
	end
end

function SWEP:PrimaryAttack()
	BaseClass.PrimaryAttack(self)
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
end

function SWEP:SecondaryAttack()
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

function SWEP:ShootBullet()
	--debug.Trace()
	local owner = self:GetOwner()

	local bullet_ang = owner:EyeAngles() + owner:GetViewPunchAngles()

	local bullet_info = self.Bullets

	local bullet = {
		Num = 1,
		Attacker = owner,
		Damage = bullet_info.Damage,
		Tracer = bullet_info.Tracer,
		TracerName = bullet_info.TracerName,
		Spread = vector_origin,
		Callback = self.FireBulletsCallback,
		Src = owner:GetShootPos(),
		Dir = bullet_ang:Forward()
	}

	owner:LagCompensation(true)
	self:FireBullets(bullet)
	owner:LagCompensation(false)

	self:ShootEffects()
end



function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack()) then
		return
	end

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:EmitSound "Weapon_AR2.Single"

	self:ShootBullet(150, 1, 0.01)

	self:TakePrimaryAmmo(1)

	self.Owner:ViewPunch(Angle(-1, 0, 0))
end