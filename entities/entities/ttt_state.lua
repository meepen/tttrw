AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_entity"
ENT.PrintName = "TTT Networking State"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

function ENT:NetworkVarNotifyCallback(name, old, new)
	printf("%s::%s: %s -> %s", self:GetClass(), name, old, new)
	hook.Run("On"..name.."Change", old, new)
end

function ENT:SetupDataTables()
	local types, vars = {}, hook.Run("InitializeNetworking")

	for _, var in ipairs(vars) do
		-- blocked by issue https://github.com/Facepunch/garrysmod-requests/issues/324
		--[[
		if (not types[var.Type]) then
			types[var.Type] = 0
		end
		]]

		printf("Registering variable %s (type %s)", var.Name, var.Type)
		--self:NetworkVar(var.Type, types[var.Type], var.Name)

		local nw2getter = "GetNW2"..var.Type
		local nw2setter = "SetNW2"..var.Type
		self["Get"..var.Name] = function(self)
			return self[nw2getter](self, var.Name) or 0
		end
		self["Set"..var.Name] = function(self, value)
			self[nw2setter](self, var.Name, value)
		end

		if (SERVER and var.Default) then
			self["Set"..var.Name](self, var.Default)
		end

		self:SetNWVarProxy(var.Name, self.NetworkVarNotifyCallback)

		--self:NetworkVarNotify(var.Name, self.NetworkVarNotifyCallback)

		--types[var.Type] = types[var.Type] + 1
	end
end

function ENT:Initialize()
	self:SetPredictable(false)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

hook.Add("TTTAddPermanentEntities", "ttt_state", function(list)
	table.insert(list, "ttt_state")
end)