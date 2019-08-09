

if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)
	
	hook.Add("EntityTakeDamage", "ttt_equipment_EntityTakeDamage", function(pl, dmg)
		for _, eq in pairs(pl.Equipment) do
			if (eq.Equipment_EntityTakeDamage) then
				eq:Equipment_EntityTakeDamage(dmg)
			end
		end
	end)


	-- Development command
	concommand.Add("i_want_equipment", function(ply, cmd, args)
		if (not ply:GetUserGroup("superadmin")) then return end

		local eq = ents.Create(args[1])
		eq:SetParent(ply)
		eq:Spawn()
	end)
else
	TTT_Equipment = {}
end
