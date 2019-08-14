ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar("Float",  0, "Delay")
	self:NetworkVar("Float",  1, "NextUseTime")
	self:NetworkVar("Bool",   0, "Locked")
	self:NetworkVar("String", 0, "Description")
	self:NetworkVar("Int",    0, "UsableRange", {KeyName = "UsableRange"})
end

function ENT:OnReloaded()
	hook.Add("FindUseEntity", self, self.FindUseEntity)
end

function ENT:Initialize()
	if (CLIENT) then
		self:CL_Initialize()
	else
		self:SV_Initialize()
	end
	self:OnReloaded()
end

function ENT:FindUseEntity(ply, ent)
	local plypos = ply:EyePos()
	local pos = self:GetPos()

	if (plypos:Distance(pos) > self:GetUsableRange()) then
		return
	end

	local dot = (pos - plypos):GetNormalized():Dot(ply:EyeAngles():Forward())

	return dot > 0.995 and self or nil
end

function ENT:IsUsable()
    return not self:GetLocked() and self:GetNextUseTime() < CurTime() and ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE
end

function ENT:PlayerCanSee(ply)
	return IsValid(ply) and ply:GetTeam() == "traitor"
end