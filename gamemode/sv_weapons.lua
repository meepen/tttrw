function GM:PlayerCanPickupWeapon(ply, wep)
	local weps = ply:GetWeapons()

	for _, curwep in pairs(ply:GetWeapons()) do
		if (wep:GetSlot() == curwep:GetSlot()) then
			return false
		end
	end

	wep:SetPos(ply:GetShootPos())

	return true
end

function GM:WeaponEquip(wep, ply)
	if (wep.StoredAmmo) then
		local pri = wep:GetPrimaryAmmoType()
		ply:SetAmmo(wep.StoredAmmo + ply:GetAmmoCount(pri), pri)
		wep.StoredAmmo = nil
	end
end

function GM:DropCurrentWeapon(ply)
	local wep = ply:GetActiveWeapon()

	if (not IsValid(wep)) then
		return
	end

	ply:DropWeapon(wep)

	local pri = wep:GetPrimaryAmmoType()

	for _, otherwep in pairs(ply:GetWeapons()) do
		if (otherwep:GetPrimaryAmmoType() == pri) then
			return
		end
	end

	wep.StoredAmmo = ply:GetAmmoCount(pri)

	ply:SetAmmo(0, pri)
end