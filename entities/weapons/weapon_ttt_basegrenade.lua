AddCSLuaFile()

SWEP.HoldType           = "slam"

SWEP.PrintName          = "Incediary Grenada"
SWEP.Slot               = 3

SWEP.ViewModelFlip      = true
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = false

SWEP.Primary.Delay = 3

SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.ViewModel             = "models/weapons/v_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.GrenadeEntity = "ttt_basegrenade"

DEFINE_BASECLASS "weapon_tttbase"
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetVar("ThrowStart", "Float", 0)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self.DoThrow = true
	self:SetThrowStart(CurTime())

	self:PullPin()
end

function SWEP:Throw()
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
		e:SetDieTime(self:GetThrowStart() + self.Primary.Delay)
		e:Spawn()

		hook.Run("DropCurrentWeapon", self:GetOwner())
		self:Remove()
	end
end

function SWEP:Think()
	if (self.DoThrow) then
		if (not IsValid(self:GetOwner())) then
			self.DoThrow = false
			return
		end

		if (not self:GetOwner():KeyDown(IN_ATTACK) or self:GetThrowStart() + self.Primary.Delay < CurTime()) then
			self:Throw()
		end
	end

end

function SWEP:PullPin()
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	if self.SetHoldType then
		self:SetHoldType "grenade"
	end
end

function SWEP:SecondaryAttack()
end

function SWEP:TranslateFOV(fov)
	return hook.Run("TTTGetFOV", fov) or fov
end

function SWEP:Holster()
	self.DoThrow = false

	return BaseClass.Holster(self)
end