AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "AK47"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_ak47"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_AK47

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.03, .03, .03)
}

SWEP.Primary.Damage        = 8
SWEP.Primary.Delay         = 0.08
SWEP.Primary.Recoil        = 3.4
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "ar2"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_AK47.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_ar2_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_ak47.mdl"

SWEP.Ironsights = {
	Pos = Vector(-7.8, -9.2, 0.55),
	Angle = Vector(3.3, -2.7, -5),
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