AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "Pistol"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {1.5, 4.2, size = 1.1}

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 2500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.02, .02)
}

SWEP.TTTCompat = {"weapon_zm_pistol"}

SWEP.Primary.Damage        = 25
SWEP.Primary.Delay         = 0.4
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 16
SWEP.Primary.DefaultClip   = 32
SWEP.Primary.Sound         = Sound "Weapon_FiveSeven.Single"

SWEP.HeadshotMultiplier    = 1.9
SWEP.DeploySpeed = 2.5

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.95, -4, 2.799),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.2,
	TimeFrom = 0.15,
	SlowDown = 0.35,
	Zoom = 0.75,
}

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-25),
}