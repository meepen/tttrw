
AddCSLuaFile()

SWEP.HoldType           = "pistol"

SWEP.PrintName          = "Flare Gun"
SWEP.Slot               = 6

SWEP.ViewModelFOV       = 54
SWEP.ViewModelFlip      = false

SWEP.Base                  = "weapon_tttbase"

SWEP.Primary.Ammo          = "AR2AltFire"
SWEP.Primary.Recoil        = 4
SWEP.Primary.Damage        = 7
SWEP.Primary.Delay         = 1.0
SWEP.Primary.Cone          = 0.01
SWEP.Primary.ClipSize      = 4
SWEP.Primary.Automatic     = false
SWEP.Primary.DefaultClip   = 4
SWEP.Primary.ClipMax       = 4
SWEP.Primary.Sound         = Sound "Weapon_USP.SilencedShot"

SWEP.Equipment = {
	Name		   = "Flare Gun",
	Desc 		   = "Burns bodies to a crisp.",
	CanBuy	       = { traitor = true },
	Cost 	   	   = 1,
	Icon           = "materials/tttrw/equipment/flaregun.png"
}

SWEP.Tracer                = "AR2Tracer"

SWEP.ViewModel             = "models/weapons/c_357.mdl"
SWEP.WorldModel            = "models/weapons/w_357.mdl"

local function RunIgniteTimer(ent, timer_name)
	if IsValid(ent) and ent:IsOnFire() then
		if ent:WaterLevel() > 0 then
			ent:Extinguish()
		elseif CurTime() > ent.burn_destroy then
			ent:SetNotSolid(true)
			ent:Remove()
		else
			-- keep on burning
			return
		end
	end

	timer.Remove(timer_name) -- stop running timer
end

local SendScorches

if CLIENT then
	local function ReceiveScorches()
		local ent = net.ReadEntity()
		local num = net.ReadUInt(8)
		for i=1, num do
			util.PaintDown(net.ReadVector(), "FadingScorch", ent)
		end

		if IsValid(ent) then
			util.PaintDown(ent:LocalToWorld(ent:OBBCenter()), "Scorch", ent)
		end
	end
	net.Receive("TTT_FlareScorch", ReceiveScorches)
else
	-- it's sad that decals are so unreliable when drawn serverside, failing to
	-- draw more often than they work, that I have to do this
	util.AddNetworkString("TTT_FlareScorch")
	SendScorches = function(ent, tbl)
		net.Start("TTT_FlareScorch")
		net.WriteEntity(ent)
		net.WriteUInt(#tbl, 8)
		for _, p in pairs(tbl) do
			net.WriteVector(p)
		end
		net.Broadcast()
	end

end


local function ScorchUnderRagdoll(ent)
	if SERVER then
		local postbl = {}
		-- small scorches under limbs
		for i=0, ent:GetPhysicsObjectCount()-1 do
			local subphys = ent:GetPhysicsObjectNum(i)
			if IsValid(subphys) then
				local pos = subphys:GetPos()
				util.PaintDown(pos, "FadingScorch", ent)

				table.insert(postbl, pos)
			end
		end

		SendScorches(ent, postbl)
	end

	-- big scorch at center
	local mid = ent:LocalToWorld(ent:OBBCenter())
	mid.z = mid.z + 25
	util.PaintDown(mid, "Scorch", ent)
end


function IgniteTarget(att, path, dmginfo)
	local ent = path.Entity
	if not IsValid(ent) then return end

	if CLIENT and IsFirstTimePredicted() then
		if ent:GetClass() == "prop_ragdoll" then
			ScorchUnderRagdoll(ent)
		end
		return
	end

	if SERVER then

		local dur = ent:IsPlayer() and 5 or 10

		-- disallow if prep or post round
		if (ent:IsPlayer() and not hook.Run("PlayerShouldTakeDamage", ent, atk)) then
			return
		end

		ent:Ignite(dur, 100)

		ent.ignite_info = {att=dmginfo:GetAttacker(), infl=dmginfo:GetInflictor()}

		if ent:IsPlayer() then
			timer.Simple(dur + 0.1, function()
				if IsValid(ent) then
					ent.ignite_info = nil
					ent.was_burned = nil
				end
			end)

			ent.was_burned = {
				att = att,
				t = CurTime(),
				wep = att:GetActiveWeapon():GetClass()
			}
		elseif ent:GetClass() == "prop_ragdoll" then
			ScorchUnderRagdoll(ent)

			local burn_time = 6
			local tname = Format("ragburn_%d_%d", ent:EntIndex(), math.ceil(CurTime()))

			ent.burn_destroy = CurTime() + burn_time

			timer.Create(tname,
			0.1,
			math.ceil(1 + burn_time / 0.1), -- upper limit, failsafe
			function()
				RunIgniteTimer(ent, tname)
			end)
		end
	end
end

function SWEP:ShootFlare()
	local cone = self.Primary.Cone
	local bullet = {}
	bullet.Num       = 1
	bullet.Src       = self:GetOwner():GetShootPos()
	bullet.Dir       = self:GetOwner():GetAimVector()
	bullet.Spread    = Vector( cone, cone, 0 )
	bullet.Tracer    = 1
	bullet.Force     = 2
	bullet.Damage    = self.Primary.Damage
	bullet.TracerName = self.Tracer
	bullet.Callback = IgniteTarget

	self:GetOwner():FireBullets( bullet )
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if not self:CanPrimaryAttack() then return end

	self:EmitSound( self.Primary.Sound )

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self:ShootFlare()

	self:TakePrimaryAmmo( 1 )

	if IsValid(self:GetOwner()) then
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )

		self:GetOwner():ViewPunch( Angle( math.Rand(-0.2,-0.1) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	end

	if ( (game.SinglePlayer() && SERVER) || CLIENT ) then
		self:SetNWFloat( "LastShootTime", CurTime() )
	end
end

function SWEP:SecondaryAttack()
end