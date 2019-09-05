AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "Galil"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 550,
	DamageDropoffRangeMax = 3500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.025, 0.025, 0),
}

SWEP.Primary.Damage        = 15
SWEP.Primary.Delay         = 0.1
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "SMG1"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_GALIL.Single"

SWEP.HeadshotMultiplier    = 1.25

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_galil.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.3, 0, 0),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = .8,
}