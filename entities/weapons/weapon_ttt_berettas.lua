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
	Spread = Vector(0.06, 0.02),
}

SWEP.Primary.Damage        = 14
SWEP.Primary.Delay         = 0.135
SWEP.Primary.Recoil        = 1
SWEP.Primary.RecoilTiming  = 0.06
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