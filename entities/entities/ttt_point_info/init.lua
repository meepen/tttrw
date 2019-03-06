include "shared.lua"

function ENT:IsVisibleTo(ply)
	return self:GetParent() == ply
end

function ENT:SetupPlayerVisibility(ply)
	self:SetPreventTransmit(ply, not self:IsVisibleTo(ply))
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end

function ENT:OnRoundStateChange(old, new)
	self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
end

function ENT:SV_Initialize()
	hook.Add("SetupPlayerVisibility", self, self.SetupPlayerVisibility)
end