AddCSLuaFile()

SWEP.HoldType           = "ar2"

SWEP.PrintName          = "GRENADA"
SWEP.Slot               = 3

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true

SWEP.Primary.Automatic = false

SWEP.ViewModel             = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel            = "models/weapons/w_rif_ak47.mdl"

SWEP.GrenadeEntity = "ttt_basegrenade"

function SWEP:PrimaryAttack()
	local e
	if (SERVER) then
		e = ents.Create(self.GrenadeEntity)
		e.DoRemove = true
	elseif (IsFirstTimePredicted()) then
	end

	if (IsValid(e)) then
		e:SetOrigin(self:GetOwner():EyePos())
		e:SetOwner(self:GetOwner())
		e.Owner = self:GetOwner()
		e:SETVelocity(self:GetOwner():GetAimVector() * 800 + self:GetOwner():GetVelocity() * 0.8)
		e:Spawn()
		-- self:Remove()
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:TranslateFOV(fov)
	return hook.Run("TTTGetFOV", fov) or fov
end
