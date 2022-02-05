AddCSLuaFile()

SWEP.HoldType           = "pistol"
SWEP.PrintName          = "Deagle"
SWEP.Slot               = 1
SWEP.TTTCompat = {
	"weapon_zm_revolver"
}

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {0, 5, angle = Angle(0, -90, 5) }

SWEP.Base                  = "weapon_tttbase"

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 1000,
	DamageDropoffRangeMax = 5500,
	DamageMinimumPercent = 0.6,
	Spread = vector_origin,
}

SWEP.Primary.Damage        = 30
SWEP.Primary.Delay         = 0.7
SWEP.Primary.Recoil        = 3.2
SWEP.Primary.RecoilTiming  = 0.06
SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "AlyxGun"
SWEP.Primary.ClipSize      = 8
SWEP.Primary.DefaultClip   = 16
SWEP.Primary.Sound         = Sound "Weapon_Deagle.Single"

SWEP.HeadshotMultiplier    = 5
SWEP.DeploySpeed = 1.55

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_pist_deagle.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_deagle.mdl"

SWEP.Ironsights = {
	Pos = Vector(-6.361, -3.701, 2.15),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.25,
	SlowDown = 0.75,
	Zoom = 0.9,
}

SWEP.RecoilInstructions = {
	Interval = 1,
	Angle(-50),
}