AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "ttt_body_info"

function ENT:SetupDataTables()
    self:NetVar("Index", "Int")
	self:NetVar("DNAEntity", "Entity")
end

function ENT:GetIcon()
	return IsValid(self:GetDNAEntity()) and "materials/tttrw/dna.png" or "materials/tttrw/expired_dna.png"
end

function ENT:GetAutoUpdateDescription()
	return true
end

function ENT:GetDescription()
	if (IsValid(self:GetDNAEntity())) then
		return string.format("This body has DNA that will expire in %.2f seconds", self:GetDNAEntity():GetExpireTime() - CurTime())
	else
		return "This body has DNA, but it seems expired"
	end
end

function ENT:GetTitle()
	return IsValid(self:GetDNAEntity()) and "DNA" or "Expired DNA"
end

