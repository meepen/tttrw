AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "Pistol"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.IconLetter         = "u"

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
SWEP.Primary.Delay         = 0.5
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 16
SWEP.Primary.DefaultClip   = 64
SWEP.Primary.Sound         = Sound "Weapon_FiveSeven.Single"

SWEP.HeadshotMultiplier    = 1.43
SWEP.DeploySpeed = 1.66



SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.95, -4, 2.799),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.85,
}