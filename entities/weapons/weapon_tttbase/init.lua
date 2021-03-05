AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
AddCSLuaFile "cl_muzzle.lua"
include "shared.lua"

resource.AddFile "materials/tttrw/scope.vmt"

function SWEP:Equip()
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

	local own = self:GetOwner()

	for k, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if (rag.HiddenState and IsValid(rag.HiddenState:GetPlayer()) and rag.HiddenState:GetPlayer() == own) then
			own = rag
			break
		end
	end

	local dna = gmod.GetGamemode():CreateDNAData(own)
	dna:SetParent(self)
	dna:Spawn()
end


-- TODO(meep): hidden weapons so people can't cheat to see weapons

function SWEP:SetupPlayerVisibility(ply)
	self:SetPreventTransmit(ply, IsValid(self:GetOwner()) and ply:Alive())
end

function SWEP:SV_Initialize()
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end

concommand.Remove "gmod_undo"

concommand.Add("gmod_undo", function(ply)
	if (not IsValid(ply)) then
		return
	end

	local wep = ply:GetActiveWeapon()
	if (not IsValid(wep) or not wep.Primary or not wep.Primary.Ammo) then
		return
	end
	
	local ent = ttt.ammo.findent(wep.Primary.Ammo)
	if (not ent) then
		return
	end

	local amt = wep:Clip1()
	if (amt < 1 or amt <= (wep.Primary.ClipSize * 0.25)) then
	   return
	end

	local pos, ang = ply:GetShootPos(), ply:EyeAngles()
	local dir = (ang:Forward() * 32) + (ang:Right() * 6) + (ang:Up() * -5)
 
	local tr = util.QuickTrace(pos, dir, ply)
	if tr.HitWorld then
		return
	end

	wep:SetClip1(0)

	local box = ents.Create(ent)
	if (not IsValid(box)) then
		return
	end

	box:SetOwner(ply)
	box:SetPos(pos + dir)
	box:Spawn()

	box:PhysWake()

	local phys = box:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:ApplyForceCenter(ang:Forward() * 1000)
		phys:ApplyForceOffset(VectorRand(), vector_origin)
	end

	box.AmmoAmount = amt
	timer.Simple(2, function()
		if (IsValid(box)) then
			box:SetOwner()
		end
	end)
end)