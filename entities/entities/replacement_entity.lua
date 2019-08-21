ENT.Type = "point"
ENT.Base = "base_point"

function ENT:Initialize()
    hook.Add("TTTPrepareRound", self, self.TTTPrepareRound)
    self:CreateEntity()
end

function ENT:TTTPrepareRound()
    self:CreateEntity()
end

function ENT:CreateEntity()
    local e = ents.Create(self.OverrideClass)

    if (not IsValid(e)) then
        warn("Class %s does not exist! Removing replacement entity.\n", self.OverrideClass)
        self:Remove()
        return
    end

    e:SetAngles(self:GetAngles())
    e:SetPos(self:GetPos())

    e:Spawn()
end