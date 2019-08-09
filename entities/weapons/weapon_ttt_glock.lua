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
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.028, .028, .028)
}

SWEP.Primary.Damage        = 12
SWEP.Primary.Delay         = .1
SWEP.Primary.Recoil        = .9
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_Glock.Single"

SWEP.HeadshotMultiplier    = 1.75

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
	SlowDown = 0.3
}

DEFINE_BASECLASS "weapon_tttbase"

function SWEP:DoZoom(state)
	if state then
		self:ChangeFOVMultiplier(35 / 70, self.Ironsights.TimeTo)
	else
		self:ChangeFOVMultiplier(1, self.Ironsights.TimeFrom)
	end
end

function SWEP:OnDrop()
    BaseClass.OnDrop(self)
    self:SetZoom(false)
end