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
    if (not IsValid(wep)) then
        return
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