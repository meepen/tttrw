

if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
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
