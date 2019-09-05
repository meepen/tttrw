if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)

	-- Development command
	function PLAYER:GiveEquipment(class)
		if (not self:CanReceiveEquipment(class)) then
			return false
		end

		printf("[Equipment] giving %s %s.", self:Nick(), class)

		self:SetCredits(self:GetCredits() - ttt.Equipment.List[class].Cost)
		ttt.Equipment.List[class]:OnBuy(self)
	end

	concommand.Add("weps", function(ply,cmd,arg)
		if (not ply:GetUserGroup() == "superadmin") then return end
		player.GetByID(1):StripWeapon(arg[1])
		player.GetByID(1):Give(arg[1])	
	end)
	
	concommand.Add("ttt_buy_equipment", function(ply, cmd, args)
		ply:GiveEquipment(args[1])
	end)
end

function PLAYER:CanReceiveEquipment(class)
	if (not self:GetRoleData().CanUseBuyMenu) then
		return false
	end

	local eq = ttt.Equipment.List[class]
	if (not eq) then
		return false
	end

	if (eq.Limit <= self:GetCredits()) then
		return false
	end

	if (eq.CanBuy and not (eq.CanBuy[self:GetRole()] or eq.CanBuy[self:GetRoleTeam()])) then
		return false
	end

	if (eq.Limit) then
		if (not eq.IsWeapon) then
			local children = self:GetChildren()

			local count = 0
			for _, child in pairs(self:GetChildren()) do
				if (child:GetClass() == class) then
					count = count + 1
				end
			end

			if (count >= eq.Limit) then
				return false
			end
		end
	end

	return true
end

TTT_Equipment = {}

ttt.Equipment = ttt.Equipment or {}
ttt.Equipment.List = ttt.Equipment.List or {}

function ttt.Equipment.Add(id, w)
	--print("[Equipment] Adding "..id.." to equipment list.")
	local e
	local f
	if (w) then
		e = weapons.Get(id)
		function e.Equipment:OnBuy(ply)
			ply:Give(self.ClassName)
		end
	else
		e = scripted_ents.Get(id)
		function e.Equipment:OnBuy(ply)
			local eq = ents.Create(self.ClassName)
			eq:SetParent(ply)
			eq:Spawn()
		end
	end
	local t = e.Equipment
	t.IsWeapon = w
	t.ClassName = id

	if (SERVER and t.Icon) then
		resource.AddFile(t.Icon)
	end
	ttt.Equipment.List[id] = t
end

function ttt.Equipment.Build()
	table.Empty(ttt.Equipment.List)
	print("[Equipment] Rebuilding Equipment List")
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

hook.Add("OnReloaded","ReloadEquipmentList",ttt.Equipment.Build)