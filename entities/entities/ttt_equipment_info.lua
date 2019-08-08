AddCSLuaFile()

ENT.Base = "ttt_point_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Equipment State"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

function ENT:NetworkVarNotifyCallback(name, old, new)
	printf("%s::%s: %s -> %s", self:GetClass(), name, old, new)
	hook.Run("OnEquipment"..name.."Change", self:GetParent(), old, new)
end

function ENT:SetupDataTables()
	--[[local vars = {}
	hook.Run("TTTGetHiddenPlayerVariables", vars)

	for _, var in ipairs(vars) do
		-- blocked by issue https://github.com/Facepunch/garrysmod-requests/issues/324
		--[[
		if (not types[var.Type]) then
			types[var.Type] = 0
		end
		]

		printf("Registering variable %s (type %s)", var.Name, var.Type)
		--self:NetworkVar(var.Type, types[var.Type], var.Name)
		if (SERVER and var.Default) then
			--self["Set"..var.Name](self, var.Default)
			self["SetNW2"..var.Type](self, var.Default)
		end

		local nw2getter = "GetNW2"..var.Type
		local nw2setter = "SetNW2"..var.Type
		self["Get"..var.Name] = function(_)
			return self[nw2getter](self, var.Name, var.Default) or 0
		end
		self["Set"..var.Name] = function(_, value)
			self[nw2setter](self, var.Name, value)
		end

		self:SetNW2VarProxy(var.Name, self.NetworkVarNotifyCallback)

		--self:NetworkVarNotify(var.Name, self.NetworkVarNotifyCallback)

		--types[var.Type] = types[var.Type] + 1
	end]]
end

function ENT:Initialize()
	BaseClass.Initialize(self)
	if (SERVER) then
		self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
		table.insert(self:GetParent().Equipment, self)
	else
		table.insert(TTT_Equipment, self)
	end
end

hook.Add("TTTAddPermanentEntities", "ttt_equipment_info", function(list)
	table.insert(list, "ttt_equipment_info")
end)
