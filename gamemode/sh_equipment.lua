if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)

	-- Development command
	function PLAYER:GiveEquipment(class)
		print(self)
		print(class)
		if (ttt.Equipment.List[class]) then
			print("[Equipment] giving "..self:Nick().." "..class..".")
			ttt.Equipment.List[class]:OnBuy(self)
		else
			print("[Equipment] "..class.." doesn't exist!")
		end
	end

	concommand.Add("weps", function(ply,cmd,arg)
		player.GetByID(1):StripWeapon(arg[1])
		player.GetByID(1):Give(arg[1])	
	end)
	
	concommand.Add("i_want_equipment", function(ply, cmd, args)
		if (not ply:GetUserGroup() == "superadmin") then return end
		
		if (args[2] == "all") then
			for k, v in pairs(player.GetAll()) do
				v:GiveEquipment(args[1])
			end
		else
			ply:GiveEquipment(args[1])
		end
	end)
else
	
end

TTT_Equipment = {}

ttt.Equipment = ttt.Equipment or {}
ttt.Equipment.List = ttt.Equipment.List or {}

function ttt.Equipment.Add(id,w)
	print("[Equipment] Adding "..id.." to equipment list.")
	local e
	local f
	if (w) then
		e = weapons.Get(id)
		function e.Equipment:OnBuy(ply)
			print(ply:Nick())
			ply:Give(id)
		end
	else
		e = scripted_ents.Get(id)
		function e.Equipment:OnBuy(ply)
			local eq = ents.Create(id)
			eq:SetParent(ply)
			eq:Spawn()
		end
	end
	local t = e.Equipment
	ttt.Equipment.List[id] = t
end

function ttt.Equipment.Build()
	local ents = scripted_ents.GetList()
	local weps = weapons.GetList()
	for k,v in pairs(ents) do
		if (v.t.Equipment) then
			ttt.Equipment.Add(v.t.ClassName,false)
		end
	end
	for k,v in pairs(weps) do
		if (v.Equipment) then
			ttt.Equipment.Add(v.ClassName,true)
		end
	end
end

function GM:PostGamemodeLoaded()
	ttt.Equipment.Build()
end