ENT.Type = "point"
ENT.Author = "Meepen"

local Weapons

local function Regenerate()
    Weapons = {}
    for _, ent in pairs(weapons.GetList()) do
        if (ent.AutoSpawnable and not ent.Duped) then
            table.insert(Weapons, ent.ClassName)
        end
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:SpawnWeapons()
    if (not Weapons) then
        Regenerate()
    end
    self.OverrideClass = table.Random(Weapons)
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
    if (not Weapons) then
        hook.Add("InitPostEntity", self, self.SpawnWeapons)
    else
        self:SpawnWeapons()
    end
end

function ENT:OnReloaded()
    Regenerate()
end