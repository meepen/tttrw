AddCSLuaFile()

SWEP.HoldType           = "pistol"

SWEP.PrintName          = "Glock"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {1, 4, size = 1.1}

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 350,
	DamageDropoffRangeMax = 2000,
	DamageMinimumPercent = 0.8,
	Spread = Vector(0.018, 0.018)
}

SWEP.Primary.Damage        = 14
SWEP.Primary.Delay         = 0.099
SWEP.Primary.Recoil        = 1.3
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 20 --20
SWEP.Primary.DefaultClip   = 40 --40
SWEP.Primary.Sound         = Sound "Weapon_Glock.Single"

SWEP.HeadshotMultiplier    = 1.60
SWEP.DeploySpeed = 1.5

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_glock18.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.79, -3.9982, 2.8289),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.15,
	TimeFrom = 0.1,
	SlowDown = 0.7,
	Zoom = 0.9,
}

local pow = 3
local pow_y = 0.5
SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(pow * -4, pow_y * -2),
	Angle(pow * -3, pow_y * -1),
	Angle(pow * -2, pow_y * 3),
	Angle(pow * -1, pow_y * 0),
	Angle(pow * -1, pow_y * 0),
	Angle(pow * -3, pow_y * 2),
	Angle(pow * -3, pow_y * 1),
	Angle(pow * -2, pow_y * 0),
	Angle(pow * -3, pow_y * -3),
}