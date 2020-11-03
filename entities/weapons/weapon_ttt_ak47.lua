AddCSLuaFile()

SWEP.HoldType           = "ar2"

SWEP.PrintName          = "AK47"
SWEP.Slot               = 2

SWEP.Ortho = {5, 3}

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 650,
	DamageDropoffRangeMax = 4200,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.008, 0.008),
}

SWEP.Primary.Damage        = 22
SWEP.Primary.Delay         = 0.135
SWEP.Primary.Recoil        = 2.65
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_AK47.Single"

SWEP.HeadshotMultiplier    = 1.8
SWEP.DeploySpeed = 1.3

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_ak47.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.61, 0, 1.5),
	Angle = Vector(3.1, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.4,
	Zoom = 0.8,
}

local pow = 5
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-6, -2),
	pow * Angle(-4, -1),
	pow * Angle(-2, 3),
	pow * Angle(-1, 2.5),
	pow * Angle(-3, 0),
	pow * Angle(-3, 1),
	pow * Angle(-3, -3),
}