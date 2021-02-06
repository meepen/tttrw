AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "base_entity"
ENT.PrintName = "TTT Networking State"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

function ENT:NetworkVarNotifyCallback(name, old, new)
	if (self.RealOld[name] == new) then
		return
	end
	self.RealOld[name] = old
	hook.Run("On" .. name .. "Change", old, new)
end

function ENT:SetupDataTables()
	self.RealOld = {}
	local types, vars = {}, hook.Run "InitializeNetworking"

	local types = {}

	for _, var in ipairs(vars) do
		-- blocked by issue https://github.com/Facepunch/garrysmod-requests/issues/324
		if (not types[var.Type]) then
			types[var.Type] = 0
		end

		-- printf("Registering variable %s (type %s)", var.Name, var.Type)
		self:NetworkVar(var.Type, types[var.Type], var.Name)
		self:NetworkVarNotify(var.Name, self.NetworkVarNotifyCallback)
		if (SERVER and var.Default) then
			self["Set"..var.Name](self, var.Default)
		end

		types[var.Type] = types[var.Type] + 1
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