function GM:GetSpectatingEntity(ply)
	if (ply:GetObserverMode() == OBS_MODE_IN_EYE) then
		return ply:GetObserverTarget()
	end
	return NULL
end