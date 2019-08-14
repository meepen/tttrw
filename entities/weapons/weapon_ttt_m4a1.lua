AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "M4A1"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Icon               = "vgui/ttt/icon_m16"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_M16

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.015, 0.015, 0),
}

SWEP.Primary.Damage        = 18
SWEP.Primary.Delay         = 0.1
SWEP.Primary.Recoil        = 0.8
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "ar2"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.MaxClip	   = 1000
SWEP.Primary.Sound         = Sound "Weapon_M4A1.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_ar2_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_m4a1.mdl"

SWEP.Ironsights = {
	Pos = Vector(-7.8, -9.2, 0.55),
	Angle = Vector(3.3, -2.7, -5),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.6,
}