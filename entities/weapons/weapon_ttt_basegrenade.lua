AddCSLuaFile()

SWEP.HoldType           = "ar2"

SWEP.PrintName          = "Incediary Grenada"
SWEP.Slot               = 3

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = false


SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.ViewModel             = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.GrenadeEntity = "ttt_basegrenade"

function SWEP:PrimaryAttack()
	local e
	if (SERVER) then
		e = ents.Create(self.GrenadeEntity)
		e.DoRemove = true
	end

	if (IsValid(e)) then
		e:SetOrigin(self:GetOwner():EyePos())
		e:SetOwner(self:GetOwner())
		e.Owner = self:GetOwner()
		e:SETVelocity(self:GetOwner():GetAimVector() * 800 + self:GetOwner():GetVelocity() * 0.8)
		e:Spawn()

		hook.Run("DropCurrentWeapon", self:GetOwner())
		self:Remove()
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:TranslateFOV(fov)
	return hook.Run("TTTGetFOV", fov) or fov
end
