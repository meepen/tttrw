AddCSLuaFile()

SWEP.HoldType           = "ar2"

SWEP.PrintName          = "AK47"
SWEP.Slot               = 2

SWEP.Ortho = {5, 3}

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 650,
	DamageDropoffRangeMax = 4200,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.03, 0.035)
}

SWEP.Primary.Damage        = 22
SWEP.Primary.Delay         = 0.146
SWEP.Primary.Recoil        = 2.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_AK47.Single"

SWEP.HeadshotMultiplier    = 2
SWEP.DeploySpeed = 1.3

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_ak47.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.61, 0, 1.5),
	Angle = Vector(3.1, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.4,
	Zoom = 0.8,
}