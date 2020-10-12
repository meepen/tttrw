ENT.Type = "point"
ENT.Author = "Meepen"

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:Think()
    local class = table.Random(ttt.ammo.getcache().entlookup)
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