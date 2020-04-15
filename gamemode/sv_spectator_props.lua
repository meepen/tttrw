local propspec_base = CreateConVar("ttt_spec_prop_base", "8")
local propspec_min = CreateConVar("ttt_spec_prop_maxpenalty", "-6")
local propspec_max = CreateConVar("ttt_spec_prop_maxbonus", "16")
local propspec_retime = CreateConVar("ttt_spec_prop_rechargetime", "1")
local propspec_force = CreateConVar("ttt_spec_prop_force", "110")

local function IsWhitelistedClass(cls)
	return string.match(cls, "prop_physics*") or string.match(cls, "func_physbox*")
end

local function StartSpectatingProp(ply, ent)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ent, true)

	ent.spectator = ply

	local bonus = math.Clamp(math.ceil(ply:Frags() / 2), propspec_min:GetInt(), propspec_max:GetInt())
	ply.propspec = {ent = ent, delay = 0, retime = 0, punches = 0, max = propspec_base:GetInt() + bonus}
end

local function StopSpectatingProp(ply)
	local ent = ply.propspec.ent

	if IsValid(ent) then
		ent.spectator = nil
	end

	ply.propspec = nil
	ply:SpectateEntity(nil)
	ply:Spectate(OBS_MODE_ROAMING)

	local ang = ply:EyeAngles()
	ang.r = 0
	ply:SetEyeAngles(ang)
end

function GM:SpectateProp(ply)
	local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)
	if (tr.Hit and IsValid(tr.Entity) and IsWhitelistedClass(tr.Entity:GetClass()) and not IsValid(tr.Entity.spectator)) then
		local phys = tr.Entity:GetPhysicsObject()

		if (IsValid(phys) and phys:IsMoveable()) then
			StartSpectatingProp(ply, tr.Entity)
		end
	end
end

function GM:SpectatePropKey(ply, key)
	if key == IN_DUCK then
		StopSpectatingProp(ply)
		return
	end

	-- checking if prop is still valid

	local ent = ply.propspec.ent

	if (not IsValid(ent)) then
		StopSpectatingProp(ply)
		return
	end

	local phys = ent:GetPhysicsObject()

	if (not IsValid(phys)) then
		StopSpectatingProp(ply)
		return
	end

	if (not phys:IsMoveable()) then
		StopSpectatingProp(ply)
		return
	elseif (phys:HasGameFlag(FVPHYSICS_PLAYER_HELD)) then
		return
	end

	-- checking if the player can punch the prop

	if (ply.propspec.punches < 1) then return end
	if (ply.propspec.delay > CurTime()) then return end

	ply.propspec.delay = CurTime() + 0.15

	local mass = math.min(150, phys:GetMass())
	local force = propspec_force:GetInt()
	local aim = ply:GetAimVector()

	local massforce = mass * force

	if key == IN_JUMP then
		phys:ApplyForceCenter(Vector(0, 0, massforce))
		ply.propspec.delay = CurTime() + 0.05
	elseif key == IN_FORWARD then
		phys:ApplyForceCenter(aim * massforce)
	elseif key == IN_BACK then
		phys:ApplyForceCenter(aim * (massforce * -1))
	elseif key == IN_MOVELEFT then
		phys:AddAngleVelocity(Vector(0, 0, 200))
		phys:ApplyForceCenter(Vector(0, 0, massforce / 3))
	elseif key == IN_MOVERIGHT then
		phys:AddAngleVelocity(Vector(0, 0, -200))
		phys:ApplyForceCenter(Vector(0, 0, massforce / 3))
	else
		return
	end

	ply.propspec.punches = math.max(ply.propspec.punches - 1, 0)
	ply:SetNWFloat("spectator_punches", ply.propspec.punches / ply.propspec.max)
end

function GM:SpectatePropRecharge(ply)
	if (ply.propspec.retime < CurTime()) then
		ply.propspec.punches = math.min(ply.propspec.punches + 1, ply.propspec.max)
		ply:SetNWFloat("spectator_punches", ply.propspec.punches / ply.propspec.max)

		ply.propspec.retime = CurTime() + propspec_retime:GetFloat()
	end
end

function GM:PropSpectating_PlayerDisconnected(ply)
	StopSpectatingProp(ply)
end

function GM:EntityRemoved(ent)
	if (IsValid(ent.spectator)) then
		StopSpectatingProp(ent.spectator)
	end
end