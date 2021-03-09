AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "MP5"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Ortho = {3, 7.5}

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3500,
	DamageMinimumPercent = 0.2,
	Spread = Vector(0.04, 0.035, 0),
}

SWEP.Primary.Damage        = 17
SWEP.Primary.Delay         = 0.09
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "SMG1"
SWEP.Primary.ClipSize      = 30 --30
SWEP.Primary.DefaultClip   = 60 --60
SWEP.Primary.Sound         = Sound "Weapon_MP5Navy.Single"

SWEP.HeadshotMultiplier    = 1.25
SWEP.DeploySpeed = 1.5

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_mp5.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.3, -2, 1.5),
	Angle = Vector(2, 0, 1),
	TimeTo = 0.175,
	TimeFrom = 0.175,
	SlowDown = 0.45,
	Zoom = .9,
}

local power = 5

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