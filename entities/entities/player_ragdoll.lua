AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_entity"
ENT.PrintName = "TTT Player Ragdoll State"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"


function ENT:SetupPlayerVisibility(ply)
	local shouldprevent = false
	if (ply ~= self:GetParent() and self.Hidden) then
		shouldprevent = true
	end

	self:SetPreventTransmit(ply, shouldprevent)
end

function ENT:UpdateTransmitState()
	return ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE and TRANSMIT_PVS or TRANSMIT_ALWAYS
end