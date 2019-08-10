

if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)

	-- Development command
	function PLAYER:GiveEquipment(class)
		if (TTT_Equipment[class]) then
			TTT_Equipment[class]:OnBuy(self)
		end
	end

	concommand.Add("weps", function(ply,cmd,arg)
		player.GetByID(1):StripWeapon(arg[1])
		player.GetByID(1):Give(arg[1])	
	end)
	
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
	
end

TTT_Equipment = {}

local list = file.Find("gamemodes/tttrw/gamemode/equipment/*.lua","GAME")
for k,v in pairs(list) do
	if (SERVER) then AddCSLuaFile("equipment/"..v) end
	EQUIP = {}

	EQUIP.ID = string.gsub(v,".lua","")
	
	EQUIP.Desc = "A super cool item."
	EQUIP.Cost = 1
	EQUIP.Limit = 1

	EQUIP.TraitorOnly = false
	EQUIP.DetectiveOnly = false
	
	include("equipment/"..v)

	if (EQUIP.Name == nil) then
		ErrorNoHalt("[Equipment] Item \""..v.."\" has no name!")
	elseif (EQUIP.OnBuy == nil) then
		ErrorNoHalt("[Equipment] Item \""..v.."\" has no function! Add EQUIP:OnBuy()")
	end
	TTT_Equipment[EQUIP.ID] = EQUIP
end