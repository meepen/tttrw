AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_eq_flashbang_thrown.mdl")

AccessorFunc(ENT, "dmgparent", "DamageParent")

AccessorFunc(ENT, "die_explode", "ExplodeOnDeath")
AccessorFunc(ENT, "dietime", "DieTime")

ENT.firechild = nil
ENT.fireparams = {size=120, growth=1}
ENT.fire_damage = 3
ENT.fire_delay = 0

ENT.dietime = 0
ENT.hurt_interval = 0.25

CreateConVar("ttt_fire_fallback", "0", FCVAR_ARCHIVE)

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Burning")
end

function ENT:Initialize()
	self.CreationTiming = CurTime()
	self:SetModel(self.Model)
	self:DrawShadow(false)
	self:SetNoDraw(true)

	if CLIENT and GetConVar("ttt_fire_fallback"):GetBool() then
		self.Draw = self.BackupDraw
		self:SetNoDraw(false)
	end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetHealth(99999)

	self.next_hurt = CurTime()

	self:SetBurning(false)

	if self.dietime == 0 then self.dietime = CurTime() + 20 end
end

function ENT:GetDamage()
	return self.fire_damage
end

local function SpawnFire(pos, size, attack, fuel, owner, parent)
	local fire = ents.Create("env_fire")
	if not IsValid(fire) then return end

	fire:SetParent(parent)
	fire:SetOwner(owner)
	fire:SetPos(pos)
	--no glow + delete when out + start on + last forever
	fire:SetKeyValue("spawnflags", tostring(128 + 32 + 4 + 2 + 1))
	fire:SetKeyValue("firesize", size)
	fire:SetKeyValue("fireattack", attack)
	fire:SetKeyValue("health", fuel)
	fire:SetKeyValue("damagescale", "-10") -- only neg. value prevents dmg

	fire:Spawn()
	fire:Activate()

	return fire
end

-- greatly simplified version of SDK's game_shard/gamerules.cpp:RadiusDamage
-- does no block checking, radius should be very small
local function RadiusDamage(dmginfo, pos, radius, inflictor)
	local tr = nil
	for k, vic in ipairs(ents.FindInSphere(pos, radius)) do
		if IsValid(vic) and inflictor:Visible(vic) then
            if vic:IsPlayer() and vic:Alive() and vic:Team() == TEAM_TERROR then
                dmginfo:SetDamagePosition(pos)
				vic:TakeDamageInfo(dmginfo)
			end
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.firechild) then
		self.firechild:Remove()
	end
end

function ENT:OnTakeDamage()
end

function ENT:Explode()
	local pos = self:GetPos()

	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(256)
	effect:SetRadius(256)
	effect:SetMagnitude(50)

	util.Effect("Explosion", effect, true, true)

	local dmgowner = self:GetDamageParent()
	if not IsValid(dmgowner) then
		dmgowner = self
	end
	util.BlastDamage(self, dmgowner, pos, 300, 40)
end

function ENT:Think()
	if CLIENT then return end

	if self.dietime < CurTime() then
		if self:GetExplodeOnDeath() then
			local success, err = pcall(self.Explode, self)

			if not success then
				ErrorNoHalt("ERROR CAUGHT: ttt_flame: " .. err .. "\n")
			end
		end

		if IsValid(self.firechild) then
			self.firechild:Remove()
		end

		self:Remove()
		return
	end

	if (not IsValid(self.firechild) and self.CreationTiming < CurTime() - self.fire_delay) then
		if self:WaterLevel() > 0 then
			self.dietime = 0
			return
		end

		self.firechild = SpawnFire(self:GetPos(), self.fireparams.size * math.Rand(0.7, 1.1), self.fireparams.growth, 999, self:GetDamageParent(), self)

		self:SetBurning(true)
	end

	if (IsValid(self.firechild) and self.next_hurt < CurTime()) then
		if self:WaterLevel() > 0 then
			self.dietime = 0
			return
		end

		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_BURN)
		dmg:SetDamage(self:GetDamage())
		if IsValid(self:GetDamageParent()) then
			dmg:SetAttacker(self:GetDamageParent())
		else
			dmg:SetAttacker(self)
		end
		dmg:SetInflictor(self.firechild)

		RadiusDamage(dmg, self:GetPos(), self.firechild:GetKeyValues().firesize / 2, self)

		self.next_hurt = CurTime() + self.hurt_interval
	end
end

if (not SERVER) then
    return
end

local fakefire = Material "cable/smoke"
local side = Angle(-90, 0, 0)
function ENT:BackupDraw()
	if not self:GetBurning() then return end

	local vstart = self:GetPos()
	local vend = vstart + Vector(0, 0, 90)

	side.r = side.r + 0.1

	cam.Start3D2D(vstart, side, 1)
	draw.DrawText("FIRE! IT BURNS!", "Default", 0, 0, COLOR_RED, ALIGN_CENTER)
	cam.End3D2D()

	render.SetMaterial(fakefire)
	render.DrawBeam(vstart, vend, 80, 0, 0, COLOR_RED)
end

function ENT:Draw()
end