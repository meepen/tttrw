AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "MP5"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Icon               = "vgui/ttt/icon_mp5"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 500,
	DamageDropoffRangeMax = 2800,
	DamageMinimumPercent = 0.2,
	Spread = Vector(0.02, 0.02, 0),
}

SWEP.Primary.Damage        = 17
SWEP.Primary.Delay         = 0.08
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 30 --30
SWEP.Primary.DefaultClip   = 30 --30
SWEP.Primary.MaxClip	   = 90 --90
SWEP.Primary.Sound         = Sound "Weapon_MP5Navy.Single"

SWEP.HeadshotMultiplier    = 1.25

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_mp5.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_mp5.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5, -2, 3),
	Angle = Vector(0, 0, 1),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = .9,
}