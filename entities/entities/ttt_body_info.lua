AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.Cleanup = true
ENT.IsBodyInfo = true

function ENT:NetVar(name, type, default)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)
	if (default) then
		self["Set"..name](self, default)
	end
end

function ENT:SetupDataTables()
	self:NetVar("Icon", "String")
	self:NetVar("Description", "String")
	self:NetVar("Title", "String")
	self:NetVar("Index", "Int")
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	if (SERVER) then
		self:SetIndex(self:GetParent():GetAndIncrementIndex())
	end
	hook.Run("OnBodyInfoInitialized", self)
end

function ENT:IsVisibleTo(ply)
	return self:GetParent().VisibleList[ply]
end