AddCSLuaFile()

SWEP.HoldType           = "ar2"

SWEP.PrintName          = "Steyr AUG"
SWEP.Slot               = 2

SWEP.Ortho = {9, 0}

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 650,
	DamageDropoffRangeMax = 4200,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.01, 0.02)
}

SWEP.Primary.Damage        = 18
SWEP.Primary.Delay         = 0.11
SWEP.Primary.Recoil        = 2
SWEP.Primary.Automatic     = true
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_AUG.Single"

SWEP.HeadshotMultiplier    = 1.7
SWEP.DeploySpeed = 1.3
SWEP.HasScope              = true

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.Primary.Ammo          = "smg1"

SWEP.ViewModel			= "models/weapons/cstrike/c_rif_aug.mdl"
SWEP.WorldModel			= "models/weapons/w_rif_aug.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.61, 0, 1.5),
	Angle = Vector(3.1, -3, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.4,
	Zoom = 0.3,
}

local pow = 1.5
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-6, -2),
	pow * Angle(-4, -1),
	pow * Angle(-2, 3),
	pow * Angle(-1, 0),
	pow * Angle(-1, 0),
	pow * Angle(-3, 2),
	pow * Angle(-5, 1),
	pow * Angle(-2, 0),
	pow * Angle(-3, -3),
}