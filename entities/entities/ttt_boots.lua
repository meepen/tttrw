AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Boots"
ENT.Author = "cross"
ENT.Contact = "itscrossboy@gmail.com"

function ENT:Initialize()
    local ply = self:GetParent()
    if (!IsValid(ply)) then return end
    ply:SetWalkSpeed(ply:GetWalkSpeed()*2)
    ply:SetRunSpeed(ply:GetRunSpeed()*2)
    ply:SetCrouchedWalkSpeed(ply:GetCrouchedWalkSpeed()*1.5)
end

function ENT:OnRemove()
	local ply = self:GetParent()
    if (!IsValid(ply)) then return end
    ply:SetWalkSpeed(ply:GetWalkSpeed()/2)
    ply:SetRunSpeed(ply:GetRunSpeed()/2)
    ply:SetCrouchedWalkSpeed(ply:GetCrouchedWalkSpeed()/1.5)
end