AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "SG550" --SG and G3SG1 are the same everything 
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Icon               = "vgui/ttt/icon_G3SG1"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_PISTOL
SWEP.ViewModelFOV          = 63

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 4500,
	DamageDropoffRangeMax = 7520,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.009, 0.009, 0),
}

SWEP.Primary.Damage        = 35 --SG and G3SG1 are the same everything 
SWEP.Primary.Delay         = 0.30
SWEP.Primary.Recoil        = 2
SWEP.Primary.RecoilTiming  = 0.16
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "357"
SWEP.Primary.ClipSize      = 15 --15
SWEP.Primary.DefaultClip   = 15 --15
SWEP.Primary.MaxClip	   = 15
SWEP.Primary.Sound         = Sound "Weapon_SG550.Single"
SWEP.Secondary.Sound       = Sound "Default.Zoom"
SWEP.HasScope              = true

SWEP.HeadshotMultiplier    = 2.1

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_357_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_snip_sg550.mdl"
SWEP.WorldModel            = "models/weapons/w_snip_sg550.mdl"

SWEP.Ironsights = {
	Pos = Vector(5, -15, -2),
	Angle = Vector(2.6, 1.37, 3.5),
	TimeTo = 0.075,
	TimeFrom = 0.1,
	SlowDown = 0.3,
	Zoom = 0.2,
}