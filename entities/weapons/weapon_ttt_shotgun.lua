AddCSLuaFile()

SWEP.HoldType              = "shotgun"

SWEP.PrintName          = "Shotgun"
SWEP.Slot               = 2

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 54

SWEP.Icon               = "vgui/ttt/icon_shotgun"
SWEP.IconLetter         = "B"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_HEAVY
SWEP.WeaponID              = AMMO_SHOTGUN

SWEP.Bullets = {
	HullSize = 0,
	Num = 8,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(.085, .085, .085)
}

SWEP.Primary.Damage        = 11
SWEP.Primary.Delay         = 0.8
SWEP.Primary.RecoilTiming  = 0.1
SWEP.Primary.Recoil        = 7
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "Buckshot"
SWEP.Primary.NumShots 	   = 8
SWEP.Primary.ClipSize      = 8
SWEP.Primary.DefaultClip   = 16
SWEP.Primary.MaxClip       = 32
SWEP.Primary.Sound         = Sound "Weapon_XM1014.Single"

SWEP.AutoSpawnable         = true
SWEP.Spawnable             = true
SWEP.AmmoEnt               = "item_box_buckshot_ttt"

SWEP.UseHands              = true
SWEP.ViewModel             = "models/weapons/cstrike/c_shot_xm1014.mdl"
SWEP.WorldModel            = "models/weapons/w_shot_xm1014.mdl"

SWEP.Reloading 			   = false
SWEP.ReloadTimer		   = 0

SWEP.Ironsights = {
	Pos = Vector(-6.881, -9.214, 2.66),
	Angle = Vector(-0.101, -0.7, -0.201),
	TimeTo = 0.25,
	TimeFrom = 0.15,
	SlowDown = 0.3,
	Zoom = 0.9
}

DEFINE_BASECLASS "weapon_tttbase"
 
function SWEP:Reload()
 
	--if self:GetNWBool( "reloading", false ) then return end
	if self.Reloading then return end
 
	if self:Clip1() < self.Primary.ClipSize and self:GetOwner():GetAmmoCount( self.Primary.Ammo ) > 0 then
 
	   	if self:StartReload() then
		  	return
	   	end
	end
 
end
 
function SWEP:StartReload()
	--if self:GetNWBool( "reloading", false ) then
	if self.Reloading then
	   	return false
	end
 
	self:SetIronsights( false )
 
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
	local ply = self:GetOwner()
 
	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then
	   	return false
	end
 
	local wep = self
 
	if wep:Clip1() >= self.Primary.MaxClip then
	   	return false
	end
 
	wep:SendWeaponAnim(ACT_SHOTGUN_RELOAD_START)
 
	self.ReloadTimer = (CurTime() + wep:SequenceDuration())
 
	--wep:SetNWBool("reloading", true)
	self.Reloading = true
	return true
 end
 
 function SWEP:PerformReload()
	local ply = self:GetOwner()
 
	-- prevent normal shooting in between reloads
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
	if not ply or ply:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
 
	if self:Clip1() >= self.Primary.ClipSize then return end
 
	self:GetOwner():RemoveAmmo( 1, self.Primary.Ammo, false )
	self:SetClip1( self:Clip1() + 1 )
 
	self:SendWeaponAnim(ACT_VM_RELOAD)
 
	self.ReloadTimer = (CurTime() + self:SequenceDuration())
 end
 
 function SWEP:FinishReload()
	self.Reloading = false
	self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
 
	self.ReloadTimer = (CurTime() + self:SequenceDuration())
 end
 
 function SWEP:CanPrimaryAttack()
	if self:Clip1() <= 0 then
		self:EmitSound( "Weapon_Shotgun.Empty" )
		self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
		return false
	end
	return true
 end
 
 function SWEP:Think()
	BaseClass.Think(self)
	if self.Reloading then
	   	if self:GetOwner():KeyDown(IN_ATTACK) then
		  	self:FinishReload()
		  	return
	   	end
	   	if self.ReloadTimer <= CurTime() then
 
		  	if self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0 then
			 	self:FinishReload()
		  	elseif self:Clip1() < self.Primary.ClipSize then
			 	self:PerformReload()
		  	else
			 	self:FinishReload()
			end
			return
		end
	end
 end
 
 function SWEP:Deploy()
	self.Reloading = false
	self.ReloadTimer = 0
	return BaseClass.Deploy(self)
 end
