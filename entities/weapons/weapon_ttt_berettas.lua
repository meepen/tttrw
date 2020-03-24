AddCSLuaFile()

SWEP.HoldType           = "pistol"
SWEP.PrintName          = "Dual Berettas"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {0.5, 5}

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 500,
	DamageDropoffRangeMax = 2500,
	DamageMinimumPercent = 0.4,
	Spread = Vector(0.05, 0.03),
}

SWEP.Primary.Damage        = 14
SWEP.Primary.Delay         = 0.135
SWEP.Primary.Recoil        = 1
SWEP.Primary.RecoilTiming  = nil
SWEP.Primary.Automatic     = true
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 40
SWEP.Primary.Sound         = Sound "Weapon_Elite.Single"

SWEP.HeadshotMultiplier    = 1.3
SWEP.DeploySpeed = 1.55

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.Primary.Ammo          = "pistol"
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.HoldType = "duel"
SWEP.ViewModel  = "models/weapons/cstrike/c_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"

SWEP.Ironsights = false

SWEP.Ortho = {0.5, -1, angle = Angle(90, 0, 0), size = 0.8}


local power = 24
local power_y = 2

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