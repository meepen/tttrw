AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "TMP"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.IconLetter         = "l"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 1400,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.040, 0.040, 0.00)
}

SWEP.Primary.Damage        = 12
SWEP.Primary.Delay         = 0.03
SWEP.Primary.Recoil        = 1.2
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "smg1"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_TMP.Single"

SWEP.HeadshotMultiplier    = 1.2

SWEP.AutoSpawnable         = true	
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_tmp.mdl"

SWEP.Ironsights = {
	Pos = Vector(-8.921, -9.528, 2.9),
	Angle = Vector(0.699, -5.301, -7),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.9,
}