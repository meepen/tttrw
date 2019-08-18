ENT.Type = "point"
ENT.Author = "Meepen"

local Ammos

local function IsAmmo(classname)
    DEFINE_BASECLASS(classname)
    return BaseClass and BaseClass.IsAmmo
end
local function Regenerate()
    Ammos = {}
    for ClassName, ent in pairs(scripted_ents.GetList()) do
        
        if (IsAmmo(ClassName)) then
            table.insert(Ammos, ClassName)
        end
    end
    if (#Ammos == 0) then
        Ammos = nil
    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end

function ENT:SpawnAmmo()
    if (not Ammos) then
        Regenerate()
    end
    self.OverrideClass = table.Random(Ammos)
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
    if (not Ammos) then
        hook.Add("InitPostEntity", self, self.SpawnAmmo)
    else
        self:SpawnAmmo()
    end
end