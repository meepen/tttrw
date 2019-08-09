AddCSLuaFile()

SWEP.HoldType              = "ar2"

SWEP.PrintName          = "MAC10"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_mac"
SWEP.IconLetter         = "l"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_MAC10

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.03, .03, .03)
}

SWEP.Primary.Damage        = 12
SWEP.Primary.Delay         = 0.065
SWEP.Primary.Recoil        = 1.15
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "smg1"
SWEP.Primary.ClipSize      = 30
SWEP.Primary.DefaultClip   = 1000
SWEP.Primary.Sound         = Sound "Weapon_mac10.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_ammo_smg1_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_smg_mac10.mdl"
SWEP.WorldModel            = "models/weapons/w_smg_mac10.mdl"

SWEP.Ironsights = {
	Pos = Vector(-8.921, -9.528, 2.9),
	Angle = Vector(0.699, -5.301, -7),
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