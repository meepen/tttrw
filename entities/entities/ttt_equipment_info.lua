AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Equipment State"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

ENT.Hooks = {}

function ENT:Initialize()
	BaseClass.Initialize(self)
	
	if (SERVER) then
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
		table.insert(self:GetParent().Equipment, self)
	else
		table.insert(TTT_Equipment, self)
	end
end

function ENT:OnRemove()
	BaseClass.Initialize(self)
	
	for eventName, id in pairs(self.Hooks) do
		hook.Remove(eventName, id)
	end
end

function ENT:RegisterHook(eventName, cb)
	local id = self:GetClass() .. eventName .. self:GetParent():SteamID64()
	
	self.Hooks[eventName] = id
	hook.Add(eventName, id, function(...) cb(self, ...) end)
end

