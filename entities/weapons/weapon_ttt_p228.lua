AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "P228"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {1.5, 3.7, size = 1.1}

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 400,
	DamageDropoffRangeMax = 2500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.02, 0.02)
}

SWEP.Primary.Damage        = 24
SWEP.Primary.Delay         = 0.2
SWEP.Primary.Recoil        = 1.3
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 12
SWEP.Primary.DefaultClip   = 24
SWEP.Primary.Sound         = Sound "Weapon_P228.Single"

SWEP.HeadshotMultiplier    = 1.6
SWEP.DeploySpeed = 1.66


SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_p228.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.95, -4, 2.799),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.1,
	TimeFrom = 0.15,
	SlowDown = 0.9,
	Zoom = 0.85,
}

local power = 25
local power_y = 5

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-power * 0.6, -power_y * 0.5),
	Angle(-power * 0.48, -power_y * 0.8),
	Angle(-power * 0.2, -power_y * 0.3),
	Angle(-power * 0.4, power_y * 0.2),
	Angle(-power * 0.2, power_y * 0.1),
	Angle(-power * 0.6, power_y * 0.4),
	Angle(-power * 0.35, -power_y * 0.1),
	Angle(-power * 0.2, power_y * 0.3),
	Angle(-power * 0.2, power_y * 0.1),
	Angle(-power * 0.4, -power_y * 0.1),
}