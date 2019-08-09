AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "Rifle"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 64

SWEP.Icon               = "vgui/ttt/icon_scout"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_RIFLE

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.002, .002, .002)
}

SWEP.Primary.Damage        = 35
SWEP.Primary.Delay         = 1.5
SWEP.Primary.Recoil        = 7
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "357"
SWEP.Primary.ClipSize      = 20
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_Scout.Single"

SWEP.Secondary.Sound       = Sound "Default.Zoom"

SWEP.HeadshotMultiplier    = 4

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_357_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_snip_scout.mdl"
SWEP.WorldModel            = "models/weapons/w_snip_scout.mdl"

SWEP.Ironsights = {
	Pos = Vector(5, -15, -2),
	Angle = Vector(2.6, 1.37, 3.5),
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