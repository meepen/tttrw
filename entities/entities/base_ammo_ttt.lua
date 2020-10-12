AddCSLuaFile()

ENT.Type = "anim"

-- Override these values
ENT.AmmoType = "Pistol"
ENT.AmmoAmount = 1
ENT.AmmoMax = 10
ENT.AmmoEntMax = 1
ENT.Model = Model "models/items/boxsrounds.mdl"
ENT.IsAmmo = true


function ENT:RealInit() end -- bw compat

-- Some subclasses want to do stuff before/after initing (eg. setting color)
-- Using self.BaseClass gave weird problems, so stuff has been moved into a fn
-- Subclasses can easily call this whenever they want to
function ENT:Initialize()
	self:SetModel( self.Model )

	if (SERVER) then
		self:PhysicsInit( SOLID_VPHYSICS )
	end
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_BBOX )

	self:SetCollisionGroup( COLLISION_GROUP_WEAPON)
	local b = 26
	self:SetCollisionBounds(Vector(-b, -b, -b), Vector(b,b,b))

	if SERVER then
		self:SetTrigger(true)
	end

	self.tickRemoval = false

	self.AmmoEntMax = self.AmmoAmount

	if (SERVER) then
		self:PhysWake()
	end
end

-- Pseudo-clone of SDK's UTIL_ItemCanBeTouchedByPlayer
-- aims to prevent picking stuff up through fences and stuff
function ENT:PlayerCanPickup(ply)
	if ply == self:GetOwner() then return false end

	local result = hook.Call("TTTCanPickupAmmo", nil, ply, self)
	if result then
		return result
	end

	local ent = self
	local phys = ent:GetPhysicsObject()
	local spos = phys:IsValid() and phys:GetPos() or ent:OBBCenter()
	local epos = ply:GetShootPos() -- equiv to EyePos in SDK

	local tr = util.TraceLine({start=spos, endpos=epos, filter={ply, ent}, mask=MASK_SOLID})

	-- can pickup if trace was not stopped
	return tr.Fraction == 1.0
end

ttt.ammo = ttt.ammo or {}
function ttt.ammo.getcache()
	if (ttt.ammo.cache) then
		return ttt.ammo.cache
	end

	local cache = {
		namelookup = {},
		entlookup  = {},
		idlookup   = {},
	}
	ttt.ammo.cache = cache

	for id, name in pairs(game.GetAmmoTypes()) do
		cache.namelookup[name:lower()] = name
		cache.idlookup[name] = id
	end

	for _, ent in pairs(scripted_ents.GetList()) do
		if (ent.Base ~= "base_ammo_ttt") then
			continue
		end
		local ENT = ent.t

		cache.entlookup[ENT.AmmoType] = ENT.ClassName
	end

	for _, wep in pairs(weapons.GetList()) do
		if (wep.Primary and wep.Primary.Ammo) then
			local ammotype = wep.Primary.Ammo
			if (not cache.namelookup[ammotype:lower()]) then
				if (ammotype == "none") then
					continue
				end

				print("Unknown ammo type " .. ammotype .. " for class " .. wep.ClassName)
			else
				wep.Primary.Ammo = cache.namelookup[ammotype:lower()]
			end
		end
	end

	return cache
end

function ttt.ammo.findent(ammotype)
	if (not ammotype) then
		return
	end

	local cache = ttt.ammo.getcache()

	return cache.entlookup[cache.namelookup[ammotype:lower()]]
end

function ENT:PlayerHasWeaponForAmmo(ply)
	for _, wep in pairs(ply:GetWeapons()) do
		if (wep.Primary.Ammo and wep.Primary.Ammo == self.AmmoType) then
			return true
		end
		if (wep.Secondary and wep.Secondary.Ammo and wep.Secondary.Ammo == self.AmmoType) then
			return true
		end
	end

	return false
end

function ENT:Touch(ent)
	if (SERVER and self.tickRemoval ~= true) and ent:IsValid() and ent:IsPlayer() and self:PlayerHasWeaponForAmmo(ent) and self:PlayerCanPickup(ent) then
		local ammo = ent:GetAmmoCount(self.AmmoType)
		-- need clipmax info and room for at least 1/4th
		if (self.AmmoMax >= ammo + math.ceil(self.AmmoAmount / 4)) then
			local given = self.AmmoAmount
			given = math.min(given, self.AmmoMax - ammo)
			ent:GiveAmmo(given, self.AmmoType)

			local newEntAmount = self.AmmoAmount - given
			self.AmmoAmount = newEntAmount
			
			if self.AmmoAmount <= 0 or math.ceil(self.AmmoEntMax / 4) > self.AmmoAmount then
				self.tickRemoval = true
				self:Remove()
			end
		end
	end
end