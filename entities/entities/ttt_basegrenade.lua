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
	self:NetVar("TickCreated", "Int", 0, true)
	self:NetVar("DieTime", "Float", -math.huge, true)
end

function ENT:Initialize()
	self:SetTickCreated(engine.TickCount())

	self:SetDieTime(CurTime() + 2)

	if (CLIENT and not self.Client) then
		self:SetPredictable(true)
	end

	self:SetModel(self.Model)

	hook.Add("PlayerTick", self, self.PlayerTick)
end

local function reflect(d, n)
	return d - 2 * d:Dot(n) * n
end

function ENT:Trace(from, to)
	return util.TraceHull {
		start = from,
		endpos = to,
		maxs = Vector(10, 10, 5),
		mins = Vector(-10, -10, -8),
		mask = MASK_SOLID,
		collisiongroup = COLLISION_GROUP_WEAPON,
	}
end

function ENT:SetOrigin(v)
	if (self.Client) then
		self.Origin = v
	else
		self:SetPos(v)
	end
end

function ENT:GetOrigin()
	if (self.Client) then
		return self.Origin
	else
		return self:GetPos()
	end
end

function ENT:SETVelocity(v)
	if (self.Client) then
		self.Velocity = v
	else
		self:SetAbsVelocity(v)
	end
end

function ENT:GETVelocity()
	if (self.Client) then
		return self.Velocity or vector_origin
	else
		return self:GetAbsVelocity()
	end
end


function ENT:Tick()
	if (CurTime() >= self:GetDieTime()) then
		if (self.DoRemove) then
			self:Remove()
		end
	end

	self:SETVelocity(self:GETVelocity() + Vector(0, 0, -300) * engine.TickInterval())

	local cur_pos = self:GetOrigin()
	local next_pos = cur_pos + self:GETVelocity() * engine.TickInterval()

	local tr = self:Trace(cur_pos, next_pos)

	local frac = 1

	while (not tr.StartSolid and not tr.AllSolid and tr.Hit and tr.Fraction ~= 0) do
		frac = frac - tr.Fraction

		cur_pos = tr.HitPos

		self:SETVelocity(reflect(self:GETVelocity(), tr.HitNormal) * 0.5)

		next_pos = cur_pos + self:GETVelocity() * engine.TickInterval() * frac

		tr = self:Trace(cur_pos, next_pos)
	end

	if (tr.StartSolid) then
		next_pos = cur_pos
	end

	self:SetOrigin(next_pos)
end

function ENT:Think(ply)
	local curtick = engine.TickCount()
	if (self.Client and self.LastTick == curtick) then
		return
	end
	self.LastTick = curtick

	self:Tick()

	self:NextThink(CurTime())
	return true
end

function ENT:CalcAbsolutePosition(pos, ang)
	if (self.Client) then
		return self.Origin, ang
	end

	return pos, ang
end