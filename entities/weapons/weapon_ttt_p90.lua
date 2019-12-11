AddCSLuaFile()

SWEP.HoldType              = "smg"

SWEP.PrintName          = "P90"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Ortho = {4, 5}

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 500,
	DamageDropoffRangeMax = 3200,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.06, 0.04, 0),
}

SWEP.Primary.Damage        = 15
SWEP.Primary.Delay         = 0.075
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "SMG1"
SWEP.Primary.ClipSize      = 50 --50
SWEP.Primary.DefaultClip   = 100 --50
SWEP.Primary.Sound         = Sound "Weapon_P90.Single"

SWEP.HeadshotMultiplier    = 1.30
SWEP.DeploySpeed = 1.53


SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_p90.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_p90.mdl"

SWEP.Ironsights = {
	Pos = Vector(-4, 0, 3),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.2,
	TimeFrom = 0.2,
	SlowDown = 0.4,
	Zoom = 0.8,
}