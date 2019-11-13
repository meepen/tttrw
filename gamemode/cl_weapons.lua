local in_buttons = 0

function GM:CreateMove(cmd)
    cmd:SetButtons(bit.bor(cmd:GetButtons(), in_buttons))

    if (cmd:CommandNumber() ~= 0) then
        in_buttons = 0
    end
end

function GM:OnSpawnMenuOpen()
    in_buttons = bit.bor(in_buttons, IN_WEAPON1)
    -- drop weapon
end

function GM:DropCurrentWeapon(ply)
    local nextwep

    local wep = ply:GetActiveWeapon()
    if (not IsValid(wep) or not wep.AllowDrop) then
        return
    end

	if (wep.PreDrop) then
		wep:PreDrop()
    end

    for _, _wep in pairs(ply:GetWeapons()) do
        if (not IsValid(nextwep) and _wep ~= wep or _wep:GetSlot() == 5) then
            nextwep = _wep
		end
    end

	if (IsValid(nextwep)) then
        input.SelectWeapon(nextwep)
    end
end

local hooks = {
	gm_showhelp = "ShowHelp",
	gm_showteam = "ShowTeam",
	gm_showspare2 = "ShowSpare2",
	gm_showspare1 = "ShowSpare1",
	zoom = "ShowQuickChat",
	suitzoom = "ShowQuickChat",
	["+zoom"] = "ShowQuickChat",
	["+suitzoom"] = "ShowQuickChat",
}

function GM:PlayerBindPress(ply, bind, pressed)
	bind = bind:lower()

	if (hooks[bind]) then
		return hook.Run(hooks[bind], ply, pressed)
	end

	if (bind:match"^slot%d+$") then
		if (not pressed) then
			return true
		end
		local num = tonumber(bind:match"^slot(%d+)$") - 1
		local ordered_weps = {}
		for _, wep in pairs(LocalPlayer():GetWeapons()) do
			if (wep:GetSlot() == num) then
				table.insert(ordered_weps, wep)
			end
		end

		if (#ordered_weps == 0) then
			return true
		end

		table.sort(ordered_weps, function(a, b)
			return a:GetSlotPos() < b:GetSlotPos()
		end)

		local index = 1
		for ind, wep in pairs(ordered_weps) do
			if (wep == LocalPlayer():GetActiveWeapon()) then
				index = ind
			end
		end


		input.SelectWeapon(ordered_weps[index % #ordered_weps + 1])
		
		return true
	elseif (bind == "invprev" or bind == "invnext") then
		if (not pressed) then
			return true
		end
		local ordered_weps = LocalPlayer():GetWeapons()
		table.sort(ordered_weps, function(a, b)
			return a:GetSlot() < b:GetSlot()
		end)

		if (#ordered_weps == 0) then
			return true
		end

		local index = 1

		for ind, wep in pairs(ordered_weps) do
			if (wep == LocalPlayer():GetActiveWeapon()) then
				index = ind
				break
			end
		end

		if (bind == "invnext") then
			index = index + 1
		elseif (bind == "invprev") then
			index = index - 1
		end

		input.SelectWeapon(ordered_weps[(index - 1) % #ordered_weps + 1])

		return true
	end
end

function GM:PostDrawViewModel(vm, ply, weapon)
	if (weapon.UseHands or not weapon:IsScripted()) then

		local hands = LocalPlayer():GetHands()
		if (IsValid(hands)) then
			hands:DrawModel()
		end
	end
end

function GM:PlayerSetHandsModel(ply, ent)
	print(ply:GetActiveWeapon().NoPlayerModelHands and "models/player/phoenix.mdl" or ply:GetModel())
	local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetActiveWeapon().NoPlayerModelHands and "models/player/phoenix.mdl" or ply:GetModel())
	local info = player_manager.TranslatePlayerHands(simplemodel)
	if info then
		ent:SetModel(info.model)
		ent:SetSkin(info.skin)
		ent:SetBodyGroups(info.body)
	end
end

function GM:OnViewModelChanged(vm, old, new)
	local ply = vm:GetOwner()
	if (not IsValid(ply)) then
		return
	end
	hook.Run("PlayerSetHandsModel", ply, ply:GetHands())
end