AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "Glock"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_glock"
SWEP.IconLetter         = "c"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_GLOCK

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 350,
	DamageDropoffRangeMax = 2000,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.018, .018, .028)
}

SWEP.Primary.Damage        = 11
SWEP.Primary.Delay         = 0.099
SWEP.Primary.Recoil        = 1.3
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 20 --20
SWEP.Primary.DefaultClip   = 40 --40
SWEP.Primary.MaxClip       = 40 --80
SWEP.Primary.Sound         = Sound "Weapon_Glock.Single"

SWEP.HeadshotMultiplier    = 1.60

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_glock18.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.79, -3.9982, 2.8289),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.9,
}