AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "TMP"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {0, 5}

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 200,
	DamageDropoffRangeMax = 1500,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.02, 0.07)
}

SWEP.Primary.Damage        = 10
SWEP.Primary.Delay         = 0.05
SWEP.Primary.Recoil        = 1.2
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "pistol"
SWEP.Primary.ClipSize      = 24
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_TMP.Single"

SWEP.ReloadSpeed = 2

SWEP.HeadshotMultiplier    = 1.2
SWEP.DeploySpeed = 1.7

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_tmp.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.8, 0, 1.5),
	Angle = Vector(2, 0, 2),
	TimeTo = 0.15,
	TimeFrom = 0.15,
	SlowDown = 0.7,
	Zoom = 0.9,
}

local power = 6

SWEP.RecoilInstructions = {
	Interval = 2,
	Angle(-power * 0.6, -power * 0.5),
	Angle(-power * 0.48, -power * 0.8),
	Angle(-power * 0.2, -power * 0.3),
	Angle(-power * 0.4, power * 0.2),
	Angle(-power * 0.2, power * 0.1),
	Angle(-power * 0.6, power * 0.4),
	Angle(-power * 0.35, -power * 0.1),
	Angle(-power * 0.2, power * 0.3),
	Angle(-power * 0.2, power * 0.1),
	Angle(-power * 0.4, -power * 0.1),
}
