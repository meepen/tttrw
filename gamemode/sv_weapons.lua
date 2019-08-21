function GM:PlayerCanPickupWeapon(ply, wep)
    local weps = ply:GetWeapons()

    for _, curwep in pairs(ply:GetWeapons()) do
        if (wep:GetSlotPos() == curwep:GetSlotPos()) then
            return false
        end
    end

    return true
end