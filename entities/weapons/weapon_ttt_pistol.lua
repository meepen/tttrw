AddCSLuaFile()

SWEP.HoldType              = "pistol"

SWEP.PrintName          = "Pistol"
SWEP.Slot               = 1

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_pistol"
SWEP.IconLetter         = "u"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_PISTOL
SWEP.WeaponID              = AMMO_PISTOL

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.02, .02, .02)
}

SWEP.Primary.Damage        = 25
SWEP.Primary.Delay         = 0.38
SWEP.Primary.Recoil        = 1.5
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Pistol"
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_FiveSeven.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_pistol_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_pist_fiveseven.mdl"
SWEP.WorldModel            = "models/weapons/w_pist_fiveseven.mdl"

SWEP.Ironsights = {
	Pos = Vector(-5.95, -4, 2.799),
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