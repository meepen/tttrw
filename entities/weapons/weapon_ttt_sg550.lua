AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "SG550"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Ortho = {3.0, 5}

SWEP.Base                  = "weapon_tttbase"

SWEP.ViewModelFOV          = 63

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 4500,
	DamageDropoffRangeMax = 7520,
	DamageMinimumPercent = 0.1,
	Spread = vector_origin
}

SWEP.Primary.Damage        = 35
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Recoil        = 3.7
SWEP.Primary.RecoilTiming  = 0.085
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "357"
SWEP.Primary.ClipSize      = 16
SWEP.Primary.DefaultClip   = 30
SWEP.Primary.Sound         = Sound "Weapon_SG550.Single"
SWEP.Secondary.Sound       = Sound "Default.Zoom"
SWEP.HasScope              = true
SWEP.IsSniper              = false

SWEP.HeadshotMultiplier    = 2.1
SWEP.DeploySpeed = 1.6

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel            = "models/weapons/w_snip_sg550.mdl"

SWEP.Ironsights = {
	Pos = Vector(5, -15, -2),
	Angle = Vector(2.6, 1.37, 3.5),
	TimeTo = 0.075,
	TimeFrom = 0.1,
	SlowDown = 0.3,
	Zoom = 0.2,
}

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-20),
}