AddCSLuaFile()

SWEP.HoldType           = "crossbow"

SWEP.PrintName          = "H.U.G.E"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 69

SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 700,
	DamageDropoffRangeMax = 1500,
	DamageMinimumPercent = 0.5,
	Spread = Vector(0.07, 0.07)
}

SWEP.TTTCompat = {"weapon_zm_sledge"}

SWEP.Primary.Damage        = 6
SWEP.Primary.Delay         = 0.06
SWEP.Primary.Recoil        = 2
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.ClipSize      = 150
SWEP.Primary.MaxClip	   = 150
SWEP.Primary.DefaultClip   = 300
SWEP.Primary.Sound         = Sound "Weapon_m249.Single"

SWEP.HeadshotMultiplier    = 1.25
SWEP.DeploySpeed = 1.35

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel            = "models/weapons/w_mach_m249para.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.96, -5.119, 2.349),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.8,
}