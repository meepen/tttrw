ENT.Type = "point"
ENT.Author = "Meepen"

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:Initialize()
    self.ClassName = self:GetClass():gsub("_zm_", "_ttt_")
    self.KeyValues = {}
    hook.Add("TTTPrepareRound", self, self.TTTPrepareRound)
end

function ENT:KeyValue(key, val)
    self.KeyValues[key] = val
end

function ENT:TTTPrepareRound()
    local e = ents.Create(self.ClassName)

    if (not IsValid(e)) then
        warn("Class %s does not exist! Removing replacement entity.\n", self.ClassName)
        self:Remove()
        return
    end

    e:SetAngles(self:GetAngles())
    e:SetPos(self:GetPos())

    for key, value in pairs(self.KeyValues) do
        e:SetKeyValue(key, value)
    end

    e:Spawn()
end