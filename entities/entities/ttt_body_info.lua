AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "ttt_point_info"

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Icon")
    self:NetworkVar("String", 1, "Description")
    self:NetworkVar("String", 2, "Title")
    self:NetworkVar("Int", 0, "Index")
end

function ENT:IsVisibleTo(ply)
    return self:GetParent():IsVisibleTo(ply)
end