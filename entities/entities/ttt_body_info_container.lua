AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)

function ENT:GetAndIncrementIndex()
    self.Index = (self.Index or 0) + 1
    return self.Index - 1
end

function ENT:Initialize()
    BaseClass.Initialize(self)
    if (SERVER) then
        self:SetNick(self.Information.Victim:Nick())
        self:SetRole(self.Information.Victim:GetRole())
        self.VisibleList = {}
        local variables = {}
        hook.Run("InitializeBodyData", variables, self.Information)

        for i, variable in pairs(variables) do
            local e = ents.Create "ttt_body_info"
            e:SetDescription(variable.Description or "NO DESCRIPTION")
            e:SetIcon(variable.Icon or "materials/tttrw/disagree.png")
            e:SetTitle(variable.Title or "NO TITLE")
            e:SetParent(self)
            e:Spawn()
        end
    end
    self:GetRagdoll().HiddenState = self
    self:GetPlayer().DeadState = self
    hook.Run("BodyDataInitialized", self)
end

function ENT:SetVisibleTo(ply)
    self.VisibleList[ply] = true
end

function ENT:IsVisibleTo(ply)
    return not ply:Alive() or self:GetIdentified() or self.VisibleList[ply] or false
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Identified")
    self:NetworkVar("Entity", 0, "Ragdoll")
    self:NetworkVar("String", 0, "Nick")
    self:NetworkVar("String", 1, "Role")
end

function ENT:GetPlayer()
    return self:GetOwner()
end

function ENT:SetPlayer(e)
    self:SetOwner(e)
end

function ENT:GetData()
    local data = {}

    for _, ent in pairs(self:GetChildren()) do
        if (not ent.IsBodyInfo) then
            continue
        end

        table.insert(data, ent)
    end

    table.sort(data, function(a, b)
        return a:GetIndex() < b:GetIndex()
    end)

    return data
end