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

    local curwep = wep:GetSlot()

    for _, wep in pairs(ply:GetWeapons()) do
        if (not IsValid(nextwep)) then
            nextwep = wep
        else
            if (wep:GetSlot() > curwep and wep:GetSlot() < nextwep:GetSlot() or
                curwep >= nextwep:GetSlot() and wep:GetSlot() < nextwep:GetSlot()) then
                nextwep = wep
            end
        end
    end

    if (IsValid(nextwep)) then
        input.SelectWeapon(nextwep)
    end
end

function GM:PlayerBindPress(ply, bind, pressed)
	if (bind == "gm_showhelp") then
		return self:ShowHelp(ply)
	end
	if (bind:match"^slot%d+$") then
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
