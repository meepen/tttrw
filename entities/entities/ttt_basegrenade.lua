AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = "models/weapons/w_eq_flashbang_thrown.mdl"


function ENT:NetworkVarNotifyCallback(name, old, new)
	-- printf("%s::%s %s -> %s", self:GetClass(), name, old, new)
end

function ENT:NetVar(name, type, default, notify)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)

	if (default ~= nil) then
		self["Set" .. name](self, default)
	end

	if (notify) then
		self:NetworkVarNotify(name, self.NetworkVarNotifyCallback)
	end
end

function ENT:SetupDataTables()
	self:NetVar("DieTime", "Float", -math.huge, true)
	self:NetVar("Bounciness", "Float", 0.3, true)
end

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
	self:SetModel(self.Model)
	self:DrawShadow(false)
end

local function reflect(d, n)
	return d - 2 * d:Dot(n) * n
end

ENT.Mask = MASK_SOLID
ENT.CollisionGroup = COLLISION_GROUP_PLAYERSOLID

ENT.Bounds = {
	Mins = Vector(-2, -2, -3),
	Maxs = Vector(2, 2, 3),
}

function ENT:Trace(from, to)
	local tr = util.TraceHull {
		start = from,
		endpos = to,
		maxs = self.Bounds.Maxs,
		mins = self.Bounds.Mins,
		mask = self.Mask,
		collisiongroup = self.CollisionGroup,
		filter = self:GetOwner()
	}
	return tr
end

function ENT:SetWeapon(w)
	self.WeaponData = w:GetTable()
end

function ENT:SetOrigin(v)
	self:SetNetworkOrigin(v)
end

function ENT:GetOrigin()
	return self:GetNetworkOrigin()
end

function ENT:SETVelocity(v)
	self:SetAbsVelocity(v)
end

function ENT:GETVelocity()
	return self:GetAbsVelocity()
end

function ENT:Think()
	if (CurTime() >= self:GetDieTime()) then
		if (self.DoRemove) then
			self:SetPos(self:GetOrigin())
			self:Explode()
			self:Remove()
			self.DoRemove = false
			return
		end
	end

	self:Move()

	self:NextThink(CurTime())
	if (CLIENT) then
		self:SetNextClientThink(CurTime())
		--debugoverlay.Box(self:GetOrigin(), self.Bounds.Mins, self.Bounds.Maxs, 1, color_white)
	end

	return true
end

function ENT:Move()
	if (not SERVER) then
		return
	end

	local ft = FrameTime()

	self:SETVelocity(self:GETVelocity() + Vector(0, 0, -300) * ft)

	local cur_pos = self:GetOrigin()
	local next_pos = cur_pos + self:GETVelocity() * ft

	local tr = self:Trace(cur_pos, next_pos)

	local frac = 1

	while ((not tr.StartSolid or tr.FractionLeftSolid ~= tr.Fraction) and not tr.AllSolid and tr.Hit and tr.Fraction ~= 0) do
		frac = frac - tr.Fraction

		cur_pos = tr.HitPos

		if (self:GrenadeBounce(tr)) then
			break
		end

		local old = self:GETVelocity()

		self:SETVelocity(reflect(self:GETVelocity(), tr.HitNormal) * self:GetBounciness())
		self:SetAngles(self:GetAngles() + self:GETVelocity():Angle() - old:Angle())

		next_pos = cur_pos + self:GETVelocity() * ft * frac

		tr = self:Trace(cur_pos, next_pos)
	end

	if (tr.StartSolid or tr.Fraction == 0) then
		self:SETVelocity(vector_origin)
	else
		cur_pos = tr.HitPos
		self:SetAngles(self:GetAngles() + self:GETVelocity():Angle() * 0.01 * math.min(self:GETVelocity():Length() - 10, 1))
	end

	self:SetOrigin(cur_pos)
end

function ENT:GrenadeBounce(t)
	return false
end

function ENT:StartFires(pos, num, lifetime, explode, dmgowner)
	for i = 1, num do
		local ang = Angle(-math.Rand(0, 180), math.Rand(0, 360), math.Rand(0, 360))

		local vstart = pos

		local flame = ents.Create "ttt_flame"
		flame.fire_delay = 1
		flame:SetPos(pos)
		if IsValid(dmgowner) and dmgowner:IsPlayer() then
			flame:SetDamageParent(dmgowner)
			flame:SetOwner(dmgowner)
		end
		flame:SetDieTime(CurTime() + lifetime + math.Rand(-2, 2))
		flame:SetExplodeOnDeath(explode)

		flame:Spawn()
		flame:PhysWake()

		local phys = flame:GetPhysicsObject()
		if IsValid(phys) then
			-- the balance between mass and force is subtle, be careful adjusting
			phys:SetMass(2)
			phys:ApplyForceCenter(ang:Forward() * 500)
			phys:AddAngleVelocity(Vector(ang.p, ang.r, ang.y))
		end
	end
end


function ENT:Explode()
	if (not SERVER) then
		return
	end

	self:SetNoDraw(true)
	self:SetSolid(SOLID_NONE)

	local pos = self:GetPos()

	if (util.PointContents(pos) == CONTENTS_WATER) then
	   return
	end

	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(100)
	effect:SetRadius(255)
	effect:SetMagnitude(1)

	util.Effect("Explosion", effect, true, true)

	util.BlastDamage(self, self:GetOwner(), pos, 255, 50)

	self:StartFires(pos, 10, 15, false, self:GetOwner())

	--self:SetDetonateExact(0)
end