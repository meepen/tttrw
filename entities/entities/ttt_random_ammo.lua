ENT.Type = "point"
ENT.Author = "Meepen"

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:SpawnAmmo()
    self.OverrideClass = table.Random(gmod.GetGamemode().Ammos).AmmoEnt
    local e = ents.Create(self.OverrideClass)

    if (not IsValid(e)) then
        warn("Class %s does not exist! Removing replacement entity.\n", self.OverrideClass)
        self:Remove()
        return
    end

    e:SetAngles(self:GetAngles())
    e:SetPos(self:GetPos())

    e:Spawn()

    self:Remove()
end

function ENT:Initialize()
    if (not gmod.GetGamemode() or not gmod.GetGamemode().Ammos) then
        hook.Add("InitPostEntity", self, self.SpawnAmmo)
    else
        self:SpawnAmmo()
    end
end