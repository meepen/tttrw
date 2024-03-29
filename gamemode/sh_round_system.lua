local ttt_postround_dm = CreateConVar("ttt_postround_dm", "0", FCVAR_REPLICATED, "Postround DM enable")

function ttt.GetRoleColor(role)
	role = ttt.roles[role]
	if (role) then
		if (role.Color) then
			return role.Color
		end

		local team = ttt.teams[role.Team]

		if (team and team.Color) then
			role.Color = team.Color
			return team.Color
		end
		role.Color = color_unknown
	end
	return color_unknown
end

local function pcall_(fn, ...)
	local s, e = xpcall(fn, debug.traceback, ...)

	if (not s) then
		printf("Error: %s", e)
	end
end

function GM:OnRoundStateChange(old, new)
	if (new == ttt.ROUNDSTATE_PREPARING) then
		local list = {}
		pcall_(hook.Run, "TTTAddPermanentEntities", list)
		game.CleanUpMap(false, list)
	end

	if (new == ttt.ROUNDSTATE_PREPARING) then
		pcall_(hook.Run, "TTTPrepareRound")
		if (CLIENT) then
			system.FlashWindow()
		end
	elseif (new == ttt.ROUNDSTATE_ACTIVE) then
		pcall_(hook.Run, "TTTBeginRound")
	elseif (new == ttt.ROUNDSTATE_ENDED) then
		pcall_(hook.Run, "TTTEndRound")
	end
end

function GM:PlayerSpawn(ply)
	if (SERVER) then
		self:SV_PlayerSpawn(ply)
	else
		self:CL_PlayerSpawn(ply)
	end
	ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	player_manager.RunClass(ply, "Spawn")
end

function GM:PlayerShouldTakeDamage(ply, atk)
	if (ply:GetGroundEntity() == atk and IsValid(atk) and atk ~= game.GetWorld() and not atk:IsPlayer()) then
		return false
	end

	if (IsValid(atk) and atk:IsPlayer()) then
		local state = ttt.GetRoundState()
		return state == ttt.ROUNDSTATE_ACTIVE or ttt_postround_dm:GetBool() and state == ttt.ROUNDSTATE_ENDED
	end
	return true
end

hook.Add("TTTPrepareNetworkingVariables", "RoundState", function(vars)
	table.insert(vars, {
		Name = "RoundState",
		Type = "Int",
		Enums = {
			Ended = 0,
			Preparing = 1,
			Active = 2,
			Waiting = 3
		},
		Default = 3
	})
	table.insert(vars, {
		Name = "RoundStateChangeTime",
		Type = "Float",
		Default = 0
	})
	table.insert(vars, {
		Name = "VisibleRoundEndTime",
		Type = "Float",
		Default = 0
	})
	-- TODO(meep): put this somewhere safer?
	table.insert(vars, {
		Name = "RealRoundEndTime",
		Type = "Float",
		Default = 0
	})
	table.insert(vars, {
		Name = "WinCond",
		Type = "Int",
		Enums = {
			TimeLimit = 0
		},
		Default = 0
	})
	table.insert(vars, {
		Name = "RoundSpeedup",
		Type = "Float",
		Default = 1
	})
	table.insert(vars, {
		Name = "RoundNumber",
		Type = "Int",
		Default = 0
    })
end)