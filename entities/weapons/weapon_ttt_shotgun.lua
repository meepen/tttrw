AddCSLuaFile()

SWEP.HoldType           = "shotgun"

SWEP.PrintName          = "XM1014"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {2.8, 4}

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_SHOTGUN

SWEP.Bullets = {
	HullSize = 0,
	Num = 8,
	DamageDropoffRange = 300,
	DamageDropoffRangeMax = 950,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.09, 0.06)
}

DEFINE_BASECLASS "weapon_tttbase"
function SWEP:GetHitgroupScale(hg)
	if (hg == HITGROUP_RIGHTARM or hg == HITGROUP_LEFTARM) then
		return 0.5
	end

	return BaseClass.GetHitgroupScale(self, hg)
end

SWEP.HeadshotMultiplier = 1.5

SWEP.TTTCompat = {"weapon_zm_shotgun"}

SWEP.Primary.Damage        = 5.5
SWEP.Primary.Delay         = 0.7
SWEP.Primary.RecoilTiming  = 0.1
SWEP.Primary.Recoil        = 7
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Buckshot"
SWEP.Primary.ClipSize      = 8 --8
SWEP.Primary.DefaultClip   = 16 --16
SWEP.Primary.MaxClip       = 8
SWEP.Primary.Sound         = Sound "Weapon_XM1014.Single"

SWEP.DeploySpeed = 1.2

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel            = "models/weapons/w_shot_xm1014.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.881, -9.214, 2.66),
	Angle = Vector(-0.101, -0.7, -0.201),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.9
}

DEFINE_BASECLASS "weapon_tttbase"
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("ShotgunReloadingTime", "Float", -math.huge)
end

function SWEP:SetShotgunReloading(b)
	if (b) then
		self:SetShotgunReloadingTime(CurTime())
	else
		self:SetShotgunReloadingTime(-math.huge)
	end
end

function SWEP:GetShotgunReloading()
	return self:GetShotgunReloadingTime() ~= -math.huge
end

function SWEP:Reload()
	if (self:GetShotgunReloading()) then
		return
	end

	if (self:Clip1() < self:GetMaxClip1() and self:GetOwner():GetAmmoCount( self.Primary.Ammo ) > 0) then
	   	self:StartReload()
	end
end

function SWEP:StartReload()
	if (self:GetShotgunReloading() or self.NoReload) then
		return
	end

	self:SetIronsights( false )

	self:SetNextPrimaryFire(CurTime() + self:GetDelay())

	local ply = self:GetOwner()

	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
	   	return false
	end

	local wep = self

	if (wep:Clip1() >= self:GetMaxClip1()) then
	   	return false
	end

	wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)

	self:SetShotgunReloading(true)
	return true
end

function SWEP:PerformReload()
	local ply = self:GetOwner()

	-- prevent normal shooting in between reloads
	self:SetNextPrimaryFire(CurTime() + self:GetDelay())

	if (not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0) then
		return
	end

	if (self:Clip1() >= self:GetMaxClip1()) then
		return
	end

	self:GetOwner():RemoveAmmo(1, self.Primary.Ammo, false)
	self:SetClip1(self:Clip1() + 1)

	self:SendWeaponAnim(ACT_VM_RELOAD)
	self:SetShotgunReloadingTime(CurTime())
	self:GetOwner():GetViewModel():SetPlaybackRate(self:GetReloadAnimationSpeed())
end

function SWEP:FinishReload()
	self:SetShotgunReloading(false)
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
	self:SetShotgunReloading(false)
end

function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound( "Weapon_Shotgun.Empty" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		return false
	end
	return true
end

function SWEP:GetCurrentReloadAnimationTime()
	return self:GetReloadDuration(self:GetReloadAnimationSpeed())
end

function SWEP:Think()
	BaseClass.Think(self)
	if (self:GetShotgunReloading()) then
	   	if self:GetOwner():KeyDown(IN_ATTACK) then
		  	self:FinishReload()
		  	return
	   	end
	   	if (self:GetShotgunReloadingTime() + self:GetCurrentReloadAnimationTime() <= CurTime()) then
		  	if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
			 	self:FinishReload()
		  	elseif self:Clip1() < self:GetMaxClip1() then
			 	self:PerformReload()
		  	else
			 	self:FinishReload()
			end
			return
		end
	end
end

function SWEP:Deploy()
	self:SetShotgunReloading(false)
	return BaseClass.Deploy(self)
end


SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-70),
}