AddCSLuaFile()
ENT.Type = "point"

AccessorFunc(ENT, "DNAOwner", "DNAOwner")
AccessorFunc(ENT, "OldDNA", "OldDNA")

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "ExpireTime")
	self:SetExpireTime(math.huge)
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

function ENT:Think()
	if (self:GetExpireTime() < CurTime() and SERVER) then
		self:Remove()
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
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

	if (IsValid(source)) then
		if (source.HiddenState) then
			return "Collected from " .. source.HiddenState:GetNick() .. "'s body"
		elseif (IsValid(source) and source:IsWeapon()) then
			return "Collected from " .. source:GetPrintName()
		end
	end

	return "DNA???"
end