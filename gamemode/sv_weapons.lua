function GM:PlayerCanPickupWeapon(ply, wep)
	local weps = ply:GetWeapons()

	for _, curwep in pairs(ply:GetWeapons()) do
		if (wep:GetSlot() == curwep:GetSlot()) then
			return false
		end
	end

	local tr = util.TraceLine {
		start = ply:EyePos(),
		endpos = wep:GetPos(),
		mask = MASK_PLAYERSOLID,
		collisiongroup = COLLISION_GROUP_PLAYER,
		filter = ply
	}

	if (tr.Fraction < 0.95 and tr.Entity ~= wep) then
		return false
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

	if (not IsValid(wep) or not wep.AllowDrop) then
		return
	end

	ply:DropWeapon(wep)
	local ang = wep:GetAngles()
	ang:RotateAroundAxis(Vector(0, 0, 1), 90)

	wep:SetAngles(ang)

	local pri = wep:GetPrimaryAmmoType()

	for _, otherwep in pairs(ply:GetWeapons()) do
		if (otherwep:GetPrimaryAmmoType() == pri) then
			return
		end
	end

	wep.StoredAmmo = ply:GetAmmoCount(pri)

	ply:SetAmmo(0, pri)
end