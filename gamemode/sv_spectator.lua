local function UpdatePlayerSpectating(ply, new_mode)
	local current = ply:GetObserverTarget()
	local mode = ply:GetObserverMode()
	local target
	local active = round.GetActivePlayers()
	if (mode ~= OBS_MODE_ROAMING) then
		for num, info in ipairs(active) do
			if (info.Player == current) then
				current_num = num
			end
		end

		if (current_num) then
			target = active[1 + (current_num % #active)].Player
		end
	end

	if (not IsValid(target)) then
		target = active[1].Player
	end

	if (IsValid(target)) then
		if (new_mode) then
			ply:Spectate(new_mode)
		elseif (mode ~= OBS_MODE_CHASE and mode ~= OBS_MODE_IN_EYE) then
			ply:Spectate(OBS_MODE_IN_EYE)
		end
		ply:SpectateEntity(target)
	else
		ply:Spectate(OBS_MODE_ROAMING)
	end
end

function GM:TTTPlayerRemoveSpectate(ply)
	ply:Spectate(OBS_MODE_ROAMING)
end


function GM:KeyPress(ply, key)
	if (not ply:Alive()) then
		if (key == IN_RELOAD) then
			if (IsValid(ply:GetObserverTarget())) then
				ply:SetObserverMode(ply:GetObserverMode() == OBS_MODE_CHASE and OBS_MODE_IN_EYE or OBS_MODE_CHASE)
			else
				UpdatePlayerSpectating(ply, ply:GetObserverMode() == OBS_MODE_CHASE and OBS_MODE_IN_EYE or OBS_MODE_CHASE)
			end
		elseif (key == IN_ATTACK) then
			UpdatePlayerSpectating(ply)
		end
	end
end