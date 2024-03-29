AddCSLuaFile()
ENT.Type = "point"

ENT.IsDNA = true

AccessorFunc(ENT, "DNAOwner", "DNAOwner")
AccessorFunc(ENT, "OldDNA", "OldDNA")

function ENT:NetVar(name, type, default)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)
	if (default) then
		self["Set"..name](self, default)
	end
end

function ENT:SetupDataTables()
	self:NetVar("ExpireTime", "Float", CurTime() + GetConVar("ttt_dna_max_time"):GetFloat())
end

function ENT:Initialize()
	if (not SERVER) then
		return
	end

	hook.Add("PlayerRagdollCreated", self, self.PlayerRagdollCreated)
end

function ENT:PlayerRagdollCreated(ply, rag)
	if (ply == self:GetDNAOwner()) then
		self:SetDNAOwner(rag)
	end
end

function ENT:DoExpire()
	self:Remove()
end

function ENT:Think()
	if (SERVER and self:GetExpireTime() < CurTime()) then
		self:DoExpire()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:GetImagePath()
	local source = self:GetOwner()

	if (IsValid(source)) then
		if (source.HiddenState) then
			return ttt.roles[source.HiddenState:GetRole()].DeathIcon or "tttrw/disagree.png"
		end
	end

	return "tttrw/heart.png"
end

function ENT:GetDescription()
	local source = self:GetOwner()

	if (not IsValid(source)) then
		self:SetOwner(self:GetParent())
	end

	if (IsValid(source)) then
		if (source.HiddenState) then
			return "Collected from " .. source.HiddenState:GetNick() .. "'s body"
		elseif (IsValid(source) and source:IsWeapon()) then
			return "Collected from " .. (startswithvowel(source:GetPrintName()) and " an " or " a ") .. source:GetPrintName()
		end
	end

	return "DNA???"
end