AddCSLuaFile()

SWEP.HoldType           = "slam"

SWEP.PrintName          = "Incediary Grenada"
SWEP.Slot               = 3

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Base                  = "weapon_tttbase"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = false

SWEP.Primary.Delay = 3

SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false

SWEP.ViewModel             = "models/weapons/cstrike/c_eq_flashbang.mdl"
SWEP.WorldModel            = "models/weapons/w_eq_flashbang.mdl"

SWEP.GrenadeEntity = "ttt_basegrenade"

DEFINE_BASECLASS "weapon_tttbase"
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)

	self:NetVar("ThrowStart", "Float", math.huge)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
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


		self:SetThrowStart(math.huge)
		hook.Run("DropCurrentWeapon", self:GetOwner())
		self:Remove()
	end
end

function SWEP:Think()
	if (self:GetThrowStart() ~= math.huge and (not self:GetOwner():KeyDown(IN_ATTACK) or self:GetThrowStart() + self.Primary.Delay < CurTime())) then
		self:Throw()
	end
end

function SWEP:PullPin()
	self:SendWeaponAnim(ACT_VM_PULLPIN)

	self:SetHoldType "grenade"
end

function SWEP:SecondaryAttack()
end

function SWEP:TranslateFOV(fov)
	return hook.Run("TTTGetFOV", fov) or fov
end

function SWEP:PreDrop()
	if (self:GetThrowStart() ~= math.huge) then
		return true
	end
end

function SWEP:Holster()
	if (self:GetThrowStart() ~= math.huge) then
		return false
	end

	return BaseClass.Holster(self)
end