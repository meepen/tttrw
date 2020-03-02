AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "M4A1"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Ortho = {5, 3}

SWEP.Base                  = "weapon_tttbase"

SWEP.TTTCompat = {
	"weapon_ttt_m16"
}

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 650,
	DamageDropoffRangeMax = 5500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.008, 0.008),
}

SWEP.Primary.Damage        = 19
SWEP.Primary.Delay         = 0.1249
SWEP.Primary.Recoil        = 1.76
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_M4A1.Single"

SWEP.HeadshotMultiplier    = 1.7
SWEP.DeploySpeed = 1.4

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_m4a1.mdl"

SWEP.Ironsights = {
	Pos = Vector(-7.8, -9.2, 0.55),
	Angle = Vector(3.3, -2.7, -5),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.35,
	Zoom = 0.6,
}

local pow = 1.35
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-6, -2),
	pow * Angle(-4, -1),
	pow * Angle(-2, 3),
	pow * Angle(-1, 0),
	pow * Angle(-1, 0),
	pow * Angle(-3, 2),
	pow * Angle(-3, 1),
	pow * Angle(-2, 0),
	pow * Angle(-3, -3),
}