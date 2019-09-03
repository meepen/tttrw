AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "Deagle"
SWEP.Slot               = 1
SWEP.TTTCompat = {
	"weapon_zm_revolver"
}

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_deagle"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_DEAGLE

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 1000,
	DamageDropoffRangeMax = 5500,
	DamageMinimumPercent = 0.3,
	Spread = Vector(.01, .01, .01)
}

SWEP.Primary.Damage        = 37
SWEP.Primary.Delay         = 0.66
SWEP.Primary.Recoil        = 3.2
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "AlyxGun"
SWEP.Primary.ClipSize      = 8
SWEP.Primary.DefaultClip   = 16
SWEP.Primary.Sound         = Sound "Weapon_Deagle.Single"

SWEP.HeadshotMultiplier    = 4.2

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_revolver_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_deagle.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.361, -3.701, 2.15),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.9,
}