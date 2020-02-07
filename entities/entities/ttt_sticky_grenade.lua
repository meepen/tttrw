AddCSLuaFile()

ENT.PrintName = "Sticky Grenade"
ENT.Base = "ttt_basegrenade"

DEFINE_BASECLASS "ttt_basegrenade"

sound.Add {
	name = "sticky_grenade",
	channel = CHAN_STATIC,
	volume = 1,
	level = 80,
	pitch = 70,
	sound = "weapons/c4/c4_beep1.wav"
}

function ENT:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("Stuck", "Bool", false)
	self:NetVar("NextSound", "Float")
end

function ENT:Collide(tr)
	self:SetStuck(true)
	if (tr.Entity ~= game.GetWorld()) then
		self:SetParent(tr.Entity)
		self:SetLocalPos(tr.Entity:WorldToLocal(tr.HitPos))
		self:SetLocalAngles(tr.Entity:GetAngles())
	end

	return true
end

function ENT:Move()
	if (self:GetStuck()) then
		return
	end

	return BaseClass.Move(self)
end

function ENT:Tick()
	if (SERVER) then
		local left = self:GetDieTime() - CurTime()

		local interval = 0.5
		if (left < 1) then
			interval = 0.1
		elseif (left < 2.5) then
			interval = 0.3
		end

		if (self:GetNextSound() == -math.huge or self:GetNextSound() < CurTime()) then
			self:EmitSound "sticky_grenade"
			self:SetNextSound(CurTime() + interval)
		end
	end

	BaseClass.Tick(self)
end

local size = 100
function ENT:Think()
	if (CLIENT) then
		local dlight = DynamicLight(self:EntIndex(), false)

		dlight.Pos = IsValid(self:GetParent()) and self:LocalToWorld(vector_origin) or self:GetOrigin()
		dlight.r = 255
		dlight.g = 0
		dlight.b = 255
		dlight.Brightness = 1

		local mul = (CurTime() % 0.5) / 0.5
		dlight.Decay = mul * size * 5
		dlight.Size = mul * size

		dlight.DieTime = self:GetDieTime()

		dlight.noworld = false
		dlight.nomodel = false
		dlight.outerangle = 360
		dlight.innerangle = 360
	end
end

local max_dist = 150

function ENT:Explode()

	for k,v in pairs(ents.GetAll()) do
		local dist = v:GetPos():Distance(self:GetOrigin())

		if (dist < max_dist) then

			local tr = util.TraceLine {
				start = self:GetOrigin(),
				endpos = v:GetPos(),
				mask = MASK_SHOT,
				filter = self,
			}

			if (v:IsPlayer()) then
				print(v)
				PrintTable(tr)
			end

			if (not tr.Hit and tr.Entity ~= v and tr.Fraction ~= 1) then
				continue
			end

			local dmg = DamageInfo()
			dmg:SetDamageCustom(0)
			dmg:SetDamage(150)
			dmg:ScaleDamage(1 - dist / max_dist)
			dmg:SetInflictor(self)
			dmg:SetAttacker(self:GetOwner())
			dmg:SetReportedPosition(v:GetPos())
			dmg:SetDamageType(DMG_BLAST)

			v:TakeDamageInfo(dmg)
		end
	end

	local pos = self:GetPos()

	
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	
	util.Effect("Explosion", effect, true, true)
	util.Effect("cball_explode", effect, true, true)
end