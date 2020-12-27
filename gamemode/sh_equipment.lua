if (SERVER) then
	hook.Add("PlayerInitialSpawn", "ttt_equipment_PlayerInitialSpawn", function(pl)
		pl.Equipment = {}
	end)

	-- Development command
	function PLAYER:GiveEquipment(class)
		local success, msg = self:CanReceiveEquipment(class)
	
		if (not success) then
			return false, msg
		end

		local eq = ttt.Equipment.List[class]

		if (eq.Cost > self:GetCredits()) then
			return false, "Not enough credits to buy this"
		end	

		if (ttt.Equipment.List[class]:OnBuy(self)) then
			self.TTTRWEquipmentTracker = self.TTTRWEquipmentTracker or {}
			self.TTTRWEquipmentTracker[class] = (self.TTTRWEquipmentTracker[class] or 0) + 1
			printf("[Equipment] gave %s %s.", self:Nick(), class)
			self:SetCredits(self:GetCredits() - eq.Cost)
			hook.Run("TTTOrderedEquipment", self, class, true, eq.Cost)
		else
			return false, "Buy failed."
		end
	end
	
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
		return false, "No such equipment exists"
	end

	if (eq.CanBuy and not (eq.CanBuy[self:GetRole()] or eq.CanBuy[self:GetRoleTeam()])) then
		return false, "You cannot buy that on that role"
	end

	if (eq.Limit and self.TTTRWEquipmentTracker and self.TTTRWEquipmentTracker[class] and self.TTTRWEquipmentTracker[class] >= eq.Limit) then
		return false, "You bought too many."
	end

	return true
end

function GM:EquipmentReset()
	for _, ply in pairs(player.GetAll()) do
		ply.TTTRWEquipmentTracker = {}
	end
end

TTT_Equipment = {}

ttt.Equipment = ttt.Equipment or {}
ttt.Equipment.List = ttt.Equipment.List or {}

function ttt.Equipment.Add(id, w)
	local e
	local f
	if (w) then
		e = weapons.Get(id)
		function e.Equipment:OnBuy(ply)
			local wep = ply:Give(self.ClassName)
			return IsValid(wep) and IsValid(wep:GetOwner())
		end
	else
		e = scripted_ents.Get(id)
		function e.Equipment:OnBuy(ply)
			local eq = ents.Create(self.ClassName)
			eq:SetParent(ply)
			eq:Spawn()

			return true
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