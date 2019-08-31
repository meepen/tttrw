AddCSLuaFile()
SWEP.HoldType                = "melee"

SWEP.PrintName            = "Crowbar"
SWEP.Slot                 = 0

SWEP.DrawCrosshair        = false
SWEP.ViewModelFlip        = false
SWEP.ViewModelFOV         = 54

SWEP.Icon                 = "vgui/ttt/icon_cbar"

SWEP.Base                    = "weapon_tttbase"

SWEP.UseHands                = true
SWEP.ViewModel               = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel              = "models/weapons/w_crowbar.mdl"

SWEP.Primary.Damage          = 20
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip     = -1
SWEP.Primary.Automatic       = true
SWEP.Primary.Delay           = 0.5
SWEP.Primary.Ammo            = "none"

SWEP.Secondary.ClipSize      = -1
SWEP.Secondary.DefaultClip   = -1
SWEP.Secondary.Automatic     = true
SWEP.Secondary.Ammo          = "none"
SWEP.Secondary.Delay         = 5

SWEP.NoSights                = true
SWEP.IsSilent                = true

SWEP.AutoSpawnable           = false
SWEP.AllowDelete             = false -- never removed for weapon reduction
SWEP.AllowDrop               = false

local sound_single = Sound "Weapon_Crowbar.Single"
local sound_open = Sound "DoorHandles.Unlocked3"

if SERVER then
	CreateConVar("ttt_crowbar_unlocks", "1", FCVAR_ARCHIVE)
	CreateConVar("ttt_crowbar_pushforce", "395", FCVAR_NOTIFY)
end

-- only open things that have a name (and are therefore likely to be meant to
-- open) and are the right class. Opening behaviour also differs per class, so
-- return one of the OPEN_ values
local function OpenableEnt(ent)
	local cls = ent:GetClass()
	if ent:GetName() == "" then
		return false
	elseif cls == "prop_door_rotating" then
		return "rot"
	elseif cls == "func_door" or cls == "func_door_rotating" then
		return "doors"
	elseif cls == "func_button" then
		return "buttons"
	elseif cls == "func_movelinear" then
		return "other"
	else
		return false
	end
end

local function CrowbarCanUnlock(t)
	return not GAMEMODE.crowbar_unlocks or GAMEMODE.crowbar_unlocks[t == "rot" and "doors" or t]
end

-- will open door AND return what it did
function SWEP:TryOpen(hitEnt)
	-- Get ready for some prototype-quality code, all ye who read this
	if (not SERVER or not GetConVar("ttt_crowbar_unlocks"):GetBool()) then
		return false
	end
	local openable = OpenableEnt(hitEnt)
	if (not openable or not CrowbarCanUnlock(openable)) then
		return false
	end

	if (openable == "doors" or openable == "rot") then
		hitEnt:Fire("Unlock", nil, 0)

		if (openable == "rot") then
			hitEnt:Fire("OpenAwayFrom", self:GetOwner(), 0)
		end
		hitEnt:Fire("Toggle", nil, 0)
	elseif (openable == "buttons") then
		hitEnt:Fire("Unlock", nil, 0)
		hitEnt:Fire("Press", nil, 0)
	elseif (openable == "other") then
		hitEnt:Fire("Open", nil, 0)
	end

	return true
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	owner:LagCompensation(true)

	local spos = owner:GetShootPos()
	local sdest = spos + owner:GetAimVector() * 70

	local tr_main = util.TraceLine {
		start = spos,
		endpos = sdest,
		filter = owner,
		mask = MASK_SHOT_HULL
	}
	local hitEnt = tr_main.Entity

	self:EmitSound(sound_single)

	if (IsValid(hitEnt) or tr_main.HitWorld) then
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		if (not CLIENT or IsFirstTimePredicted()) then
			local edata = EffectData()
			edata:SetStart(spos)
			edata:SetOrigin(tr_main.HitPos)
			edata:SetNormal(VectorRand())
			edata:SetSurfaceProp(tr_main.SurfaceProps)
			edata:SetHitBox(tr_main.HitBox)
			edata:SetDamageType(DMG_CLUB)
			edata:SetEntity(hitEnt)

			util.Effect("Impact", edata)
			if (hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll") then
				edata:SetColor(BLOOD_COLOR_RED)
				edata:SetScale(1)
				util.Effect("BloodImpact", edata, true, true)
			end
		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end


	if (SERVER) then
		-- Do another trace that sees nodraw stuff like func_button
		local tr_all = util.TraceLine {
			start = spos,
			endpos = sdest,
			filter = owner
		}
		
		owner:SetAnimation(PLAYER_ATTACK1)

		if (IsValid(hitEnt)) then
			if (not self:TryOpen(hitEnt)) then
				self:TryOpen(tr_all.Entity)
			end

			local dmg = DamageInfo()
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetAttacker(owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(owner:GetAimVector() * 1500)
			dmg:SetDamagePosition(tr_main.HitPos)
			dmg:SetDamageType(DMG_CLUB)

			hitEnt:DispatchTraceAttack(dmg, tr_main)
		else
			if tr_all.Entity and tr_all.Entity:IsValid() then
				self:OpenEnt(tr_all.Entity)
			end
		end
	end

	owner:LagCompensation(false)
end

function SWEP:SecondaryAttack()
	local owner = self:GetOwner()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	owner:LagCompensation(true)

	local tr = owner:GetEyeTrace(MASK_SHOT)

	if (tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (owner:EyePos() - tr.HitPos):Length() < 100) then
		local ply = tr.Entity

		if (SERVER and not ply:IsFrozen()) then
			local pushvel = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()

			-- limit the upward force to prevent launching
			pushvel.z = math.Clamp(pushvel.z, 50, 100)

			ply:SetVelocity(ply:GetVelocity() + pushvel)
			owner:SetAnimation(PLAYER_ATTACK1)

			ply.was_pushed = {
				att = owner,
				t = CurTime(),
				wep = self:GetClass()
			}
		end

		self:EmitSound(sound_single)      
		self:SendWeaponAnim(ACT_VM_HITCENTER)

		self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	end
	
	owner:LagCompensation(false)
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:ScaleDamage(hitgroup, dmg)
end