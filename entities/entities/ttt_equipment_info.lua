AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Equipment State"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

function ENT:Initialize()
	BaseClass.Initialize(self)
	
	if (SERVER) then
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
		table.insert(self:GetParent().Equipment, self)
	else
		table.insert(TTT_Equipment, self)
	end
end

function ENT:RegisterHook(eventName, cb)
	hook.Add(eventName, self, function(...) cb(self, ...) end)
end
