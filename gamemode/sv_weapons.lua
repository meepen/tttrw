function GM:PlayerCanPickupWeapon(ply, wep)
    local weps = ply:GetWeapons()

    for _, curwep in pairs(ply:GetWeapons()) do
        if (wep:GetSlot() == curwep:GetSlot()) then
            return false
        end
    end

    return true
end

function GM:DropCurrentWeapon(ply)
    ply:DropWeapon(ply:GetActiveWeapon())
end