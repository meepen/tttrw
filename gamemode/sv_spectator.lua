local function UpdatePlayerSpectating(ply, new_mode, dir)
	local current = ply:GetObserverTarget()
	local mode = ply:GetObserverMode()
	local target
	local active = {}
	local i = 1
	for k,v in ipairs(player.GetAll()) do
		if (v:Alive()) then
			active[i] = v
			i = i + 1
		end
	end
	if (mode ~= OBS_MODE_ROAMING) then
		local current_num

		for num, info in ipairs(active) do
			if (info == current) then
				current_num = num
			end
		end

		if (current_num) then
			target = active[(current_num - 1 + 1 * dir) % #active + 1]
		end
	end

	if (not IsValid(target)) then
		target = active[1]
	end

	if (IsValid(target)) then
		if (new_mode) then
			ply:Spectate(new_mode)
		elseif (mode ~= OBS_MODE_CHASE and mode ~= OBS_MODE_IN_EYE) then
			ply:Spectate(OBS_MODE_IN_EYE)
		end
		ply:SpectateEntity(target)
		ply:SetupHands(target)
	else
		ply:Spectate(OBS_MODE_ROAMING)
		ply:SetMoveType(MOVETYPE_NOCLIP)
	end
end

function GM:TTTPlayerRemoveSpectate(ply)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetMoveType(MOVETYPE_NOCLIP)
end

function GM:Spectate_PostPlayerDeath(ply)
	for _, spec in pairs(player.GetAll()) do
		if ((spec:GetObserverMode() == OBS_MODE_IN_EYE or spec:GetObserverMode() == OBS_MODE_CHASE) and spec:GetObserverTarget() == ply) then
			self:TTTPlayerRemoveSpectate(spec)
		end
	end
end

function GM:Spectate(ply)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:SetMoveType(MOVETYPE_NOCLIP)

	local ang = ply:EyeAngles()
	ang.r = 0
	ply:SetEyeAngles(ang)
end

function GM:SpectatorKey(ply, key)
	if (not ply:Alive()) then
		if (ply.propspec) then
			self:SpectatePropKey(ply, key)
		elseif (key == IN_RELOAD) then
			if (IsValid(ply:GetObserverTarget())) then
				ply:SetObserverMode(ply:GetObserverMode() == OBS_MODE_CHASE and OBS_MODE_IN_EYE or OBS_MODE_CHASE)
			else
				UpdatePlayerSpectating(ply, ply:GetObserverMode() == OBS_MODE_CHASE and OBS_MODE_IN_EYE or OBS_MODE_CHASE, 1)
			end
		elseif (key == IN_ATTACK) then
			UpdatePlayerSpectating(ply, nil, -1)
		elseif (key == IN_ATTACK2) then
			UpdatePlayerSpectating(ply, nil, 1)
		elseif (key == IN_DUCK) then
			self:Spectate(ply)
		elseif (key == IN_CANCEL) then
			self:SpectateProp(ply)
		end
	end
end