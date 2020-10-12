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
	DamageDropoffRange = 300,
	DamageDropoffRangeMax = 500,
	DamageMinimumPercent = 0.4,
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

local power = 3

SWEP.RecoilInstructions = {
	Interval = 2,
	Angle(-power * 0.6, -power * 0.5),
	Angle(-power * 0.48, -power * 0.8),
	Angle(-power * 0.2, -power * 0.3),
	Angle(-power * 0.4, power * 0.2),
	Angle(-power * 0.2, power * 0.1),
	Angle(-power * 0.6, power * 0.4),
	Angle(-power * 0.35, -power * 0.1),
	Angle(-power * 0.2, power * 0.3),
	Angle(-power * 0.2, power * 0.1),
	Angle(-power * 0.4, -power * 0.1),
}