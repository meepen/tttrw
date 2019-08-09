

if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)

	-- Development command
	function PLAYER:GiveEquipment(class)
		local eq = ents.Create(class)
		eq:SetParent(self)
		eq:Spawn()
	end
	
	concommand.Add("i_want_equipment", function(ply, cmd, args)
		if (not ply:IsSuperAdmin()) then return end
		
		if (args[2] == "all") then
			for k, v in pairs(player.GetAll()) do
				v:GiveEquipment(args[1])
			end
		else
			ply:GiveEquipment(args[1])
		end
	end)
else
	TTT_Equipment = {}
end
