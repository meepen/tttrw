AddCSLuaFile()

SWEP.HoldType              = "crossbow"

SWEP.PrintName          = "H.U.G.E"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 69

SWEP.Icon               = "vgui/ttt/icon_m249"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_M249

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 720,
	DamageDropoffRangeMax = 2500,
	DamageMinimumPercent = 0.5,
	Spread = Vector(.057, .057, .055)
}

SWEP.TTTCompat = {"weapon_zm_sledge"}

SWEP.Primary.Damage        = 6
SWEP.Primary.Delay         = 0.04
SWEP.Primary.Recoil        = 1.2
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.ClipSize      = 150
SWEP.Primary.MaxClip	   = 150
SWEP.Primary.DefaultClip   = 300
SWEP.Primary.Sound         = Sound "Weapon_m249.Single"

SWEP.HeadshotMultiplier    = 1.2

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