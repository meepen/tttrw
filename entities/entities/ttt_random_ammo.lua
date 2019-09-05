ENT.Type = "point"
ENT.Author = "Meepen"

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:Think()
    if (not gmod.GetGamemode().Ammos) then
        return
    end
    local class = table.Random(gmod.GetGamemode().Ammos).AmmoEnt
    local e = ents.Create(class)

    if (not IsValid(e)) then
        warn("Class %s does not exist! Removing replacement entity.\n", class)
        self:Remove()
        return
    end

    e:SetAngles(self:GetAngles())
    e:SetPos(self:GetPos())

    e:Spawn()

    self:Remove()
end