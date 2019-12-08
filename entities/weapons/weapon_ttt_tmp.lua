AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "TMP"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {0, 5}

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 200,
	DamageDropoffRangeMax = 3500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.050, 0.050)
}

SWEP.Primary.Damage        = 8
SWEP.Primary.Delay         = 0.05
SWEP.Primary.Recoil        = 1.2
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "pistol"
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_TMP.Single"

SWEP.ReloadSpeed = 2

SWEP.HeadshotMultiplier    = 1.2
SWEP.DeploySpeed = 1.95 

SWEP.AutoSpawnable         = true	
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_tmp.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.8, 0, 1.5),
	Angle = Vector(2, 0, 2),
	TimeTo = 0.15,
	TimeFrom = 0.15,
	SlowDown = 0.6,
	Zoom = 0.9,
}