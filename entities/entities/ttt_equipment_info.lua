AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Equipment State"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"
ENT.Cleanup = true

ENT.Timers = {}

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
	for id, _ in pairs(self.Timers) do
		timer.Remove(id)
	end

	BaseClass.OnRemove(self)
end

function ENT:RegisterHook(eventName, cb)
	hook.Add(eventName, self, cb)
end

function ENT:RegisterTimer(delay, rep, cb)
	local id = self:GetClass() .. self:GetParent():SteamID64() .. SysTime()
	
	self.Timers[id] = cb
	timer.Create(id, delay, rep, function() cb(self) end)
end
