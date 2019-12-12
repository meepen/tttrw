util.AddNetworkString "tttrw_damage_position"

function GM:PlayerHurt(vic, atk, rem, taken)
	if (not IsValid(atk) or not atk:IsPlayer() or taken <= 0) then
		return
	end

	net.Start "tttrw_damage_position"
		net.WriteVector(atk:GetShootPos())
		net.WriteFloat(taken)
	net.Send(vic)
end