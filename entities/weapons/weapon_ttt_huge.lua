AddCSLuaFile()

SWEP.HoldType              = "crossbow"

SWEP.PrintName          = "H.U.G.E-249"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_m249"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_M249

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.09, .09, .09)
}

SWEP.TTTCompat = {"weapon_zm_sledge"}

SWEP.Primary.Damage        = 7
SWEP.Primary.Delay         = 0.06
SWEP.Primary.Recoil        = 0.09
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "AirboatGun"
SWEP.Primary.ClipSize      = 150
SWEP.Primary.MaxClip	   = 150
SWEP.Primary.DefaultClip   = 300
SWEP.Primary.Sound         = Sound "Weapon_m249.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel            = "models/weapons/w_mach_m249para.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.96, -5.119, 2.349),
	Angle = Vector(0, 0, 0),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = .5,
}

DEFINE_BASECLASS "weapon_tttbase"

function SWEP:DoZoom(state)
	if state then
		self:ChangeFOVMultiplier(35 / 70, self.Ironsights.TimeTo)
	else
		self:ChangeFOVMultiplier(1, self.Ironsights.TimeFrom)
	end
end