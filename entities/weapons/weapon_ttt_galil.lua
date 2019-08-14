AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "Galil"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Icon               = "vgui/ttt/icon_galil"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_GALIL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.02, 0.02, 0),
}

SWEP.Primary.Damage        = 22
SWEP.Primary.Delay         = 0.12
SWEP.Primary.Recoil        = 0.9
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "ar2"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_GALIL.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_ar2_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_galil.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.3, 0, 0),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = .8,
}