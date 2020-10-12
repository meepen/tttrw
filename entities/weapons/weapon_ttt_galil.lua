AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "Galil"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Ortho = {4, 4}

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 550,
	DamageDropoffRangeMax = 3500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.045, 0.045, 0),
}

SWEP.Primary.Damage        = 17
SWEP.Primary.Delay         = 0.09
SWEP.Primary.Recoil        = 1.75
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "SMG1"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_GALIL.Single"

SWEP.HeadshotMultiplier    = 1.4
SWEP.DeploySpeed = 1.69

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_galil.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.34, 0, 2.45),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.2,
	TimeFrom = 0.15,
	SlowDown = 0.45,
	Zoom = 0.8,
}

local power = 3

SWEP.RecoilInstructions = {
	Interval = 2,
	Angle(-power, -power * 0.6),
	Angle(-power, -power * 0.48),
	Angle(-power, -power * 0.2),
	Angle(-power, power * 0.4),
	Angle(-power, power * 0.2),
	Angle(-power, power * 0.6),
	Angle(-power, power * 0.35),
	Angle(-power, power * 0.2),
	Angle(-power, -power * 0.2),
	Angle(-power, -power * 0.4),
}