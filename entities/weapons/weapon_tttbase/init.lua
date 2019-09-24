util.AddNetworkString "tttrw_developer_hitboxes"

AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

function SWEP:Equip()
    -- TODO(meep): figure out why the fuck this is happening???
    self:GetOwner():RemoveAmmo(24, "Pistol")
end

function SWEP:OnDrop()
	self.Primary.DefaultClip = 0
	self:CancelReload()
end

function SWEP:PreDrop()
	for _, ent in pairs(self:GetChildren()) do
		if (ent.IsDNA and ent:GetDNAOwner() == self:GetOwner()) then
			return
		end
	end

	local dna = gmod.GetGamemode():CreateDNAData(self:GetOwner())
	dna:SetParent(self)
	dna:Spawn()
end

local biggify_hitbox = 1.5
function SWEP:OverrideCommand(ply, cmd)
	if (self:GetOwner() ~= ply or ply:GetActiveWeapon() ~= self) then
		return
    end
    local ang = cmd:GetViewAngles()
    if (ang.r ~= 0) then
        cmd:SetViewAngles(Angle(ang.p, ang.y))
    end
	if (self.TickCount and ang.r ~= 0 and cmd:TickCount() - self.TickCount < self.Primary.Delay / engine.TickInterval() + 2 and not self.HitEntity and not cmd:IsForced()) then
		self.TickCount = nil
		local hitbox = math.Round(ang.r % 11)
		local entity = Entity(math.Round((ang.r - hitbox) / 11))

		if (not IsValid(entity) or not entity:IsPlayer()) then
			return
		end

		local collisions = self.LastHitboxes[entity]
		if (not collisions) then
			return
		end

		local tr = self.LastShootTrace
		tr.HitGroup = hitbox
		tr.Entity = entity
		local bullet = table.Copy(self.LastBullets)

		local biggify = biggify_hitbox

		local mins, maxs = collisions.Mins * (1 + biggify), collisions.Maxs * (1 + biggify)

		local origin = collisions.Pos - Vector(0, 0, (collisions.Maxs.z - collisions.Mins.z) * biggify / 2)

		local pos = util.IntersectRayWithOBB(tr.StartPos, tr.Normal * (bullet.Distance or 56756), origin, angle_zero, mins, maxs)
		if (not pos) then
			-- printf("%s tried to hit someone they didn't hit", self:GetOwner():Nick())
			-- print(origin, mins, maxs, tr.StartPos + tr.Normal * origin:Distance(tr.StartPos))
			return
        end

        local tr0 = util.TraceLine {
            start = tr.StartPos,
            endpos = pos,
            filter = ents.GetAll(),
			mask = MASK_SHOT,
        }

        if (tr0.Fraction ~= 1 and tr0.Entity ~= entity) then
			printf("%s tried to hit someone they didn't HIt omfajnsuijk", self:GetOwner():Nick())
            return
        end

		tr.HitPos = pos
		
		local res = hook.Run("EntityFireBullets", entity, bullet)
		if (res == false) then
			return
		elseif (res ~= true) then
			bullet = self.LastBullets
		end

		tr.IsFake = true

		local dmg = DamageInfo()
		dmg:SetDamage(bullet.Damage)
		dmg:SetAttacker(bullet.Attacker)
		dmg:SetInflictor(self)
		dmg:SetDamageForce(tr.Normal * (bullet.Force or 1))
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetAmmoType(self:GetPrimaryAmmoType())
		dmg:SetDamageType(DMG_BULLET)
		dmg:SetDamageCustom(hitbox)

		if (bullet.Callback) then
			bullet.Callback(entity, tr, dmg)
		end

		if (not hook.Run("ScalePlayerDamage", entity, hitbox, dmg)) then
			if (dmg:GetDamage() > entity:Health()) then
				entity:SetPos(collisions.Pos)
			end
			entity:TakeDamageInfo(dmg)
		end
	end
end

-- TODO(meep): hidden weapons so people can't cheat to see weapons