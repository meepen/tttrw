AddCSLuaFile()

SWEP.HoldType           = "normal"

SWEP.PrintName          = "Unarmed"
SWEP.Slot               = 5

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 10

SWEP.AllowDrop = false

SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"

DEFINE_BASECLASS "weapon_tttbase"

function SWEP:GetClass()
	return "weapon_ttt_unarmed"
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ShouldDropOnDie()
	return false
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
	if SERVER and IsValid(self:GetOwner()) then
	self:GetOwner():DrawViewModel(false)
	end

	self:DrawShadow(false)

	return true
end

function SWEP:Holster()
	return true
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end