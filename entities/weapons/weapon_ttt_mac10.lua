AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "MAC10"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Ortho = {2.2, 3.9}

SWEP.IconLetter         = "l"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_MAC10

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 2400,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0.040, 0.040, 0.00)
}

SWEP.TTTCompat = {"weapon_zm_mac10"}

SWEP.Primary.Damage        = 12
SWEP.Primary.Delay         = 0.063
SWEP.Primary.Recoil        = 1.2
SWEP.Primary.Automatic     = true
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 60
SWEP.Primary.Sound         = Sound "Weapon_mac10.Single"
SWEP.Primary.Ammo          = "smg1"
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.HeadshotMultiplier    = 1.4
SWEP.DeploySpeed = 2.5
SWEP.ReloadSpeed = 1.9

SWEP.AutoSpawnable         = true	
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_mac10.mdl"

SWEP.Ironsights = {
	Pos = Vector(-8.921, -9.528, 2.9),
	Angle = Vector(0.699, -5.301, -7),
	TimeTo = 0.15,
	TimeFrom = 0.15,
	SlowDown = 0.55,
	Zoom = 0.9,
}

local pow = 0.6
SWEP.RecoilInstructions = {
	Interval = 1,
	pow * Angle(-6, -2),
	pow * Angle(-4, -1),
	pow * Angle(-2, 3),
	pow * Angle(-1, 0),
	pow * Angle(-1, 0),
	pow * Angle(-3, 2),
	pow * Angle(-3, 1),
	pow * Angle(-2, 0),
	pow * Angle(-3, -3),
}