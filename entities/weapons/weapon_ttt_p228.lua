AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "P228"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_p228"
SWEP.IconLetter         = "u"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 400,
	DamageDropoffRangeMax = 2500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.02, .02)
}

SWEP.Primary.Damage        = 22
SWEP.Primary.Delay         = 0.3
SWEP.Primary.Recoil        = 1.3
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 12
SWEP.Primary.DefaultClip   = 12
SWEP.Primary.MaxClip       = 36
SWEP.Primary.Sound         = Sound "Weapon_P228.Single"

SWEP.HeadshotMultiplier    = 1.43

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_p228.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_p228.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.95, -4, 2.799),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.85,
}