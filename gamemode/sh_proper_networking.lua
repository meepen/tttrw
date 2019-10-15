function GM:InitializeNetworking()
	local vars = {}
	ttt.Enums = {}

	hook.Run("TTTPrepareNetworkingVariables", vars)

	table.SortByMember(vars, "Name")

	for id, var in ipairs(vars) do
		local index = "Get"..var.Name
		ttt[index] = function()
			local world = gmod.GetGamemode().NetworkingEntity
			return world[index](world)
		end

		local set_index = "Set"..var.Name
		local hook_name = "Prevent"..set_index
		ttt[set_index] = function(val)
			if (hook.Run(hook_name, val)) then
				return
			end
			local world = gmod.GetGamemode().NetworkingEntity
			world[set_index](world, val)
		end

		ttt.Enums[var.Name] = {}

		if (var.Enums) then
			for enum, value in pairs(var.Enums) do
				printf("%s_%s = %s", var.Name:upper(), enum:upper(), value)

				ttt.Enums[var.Name][value] = enum
				ttt[var.Name:upper().."_"..enum:upper()] = value
			end
		end
	end
	
	-- backwards compat

	function GetRoundState()
		return ttt.GetRoundState()
	end

	ROUND_ACTIVE = ttt.ROUNDSTATE_ACTIVE
	

	return vars
end

function GM:InitPostEntity_Networking()
	if (SERVER) then
		self.NetworkingEntity = ents.Create "ttt_state"
	else
		self.NetworkingEntity = ents.FindByClass "ttt_state"[1]
	end
	if (not IsValid(self.NetworkingEntity)) then
		error "NetworkingEntity is invalid!"
	end
end