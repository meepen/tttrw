local ttt_firstpreptime = CreateConVar("ttt_firstpreptime", "5", FCVAR_REPLICATED, "The wait time before the first round starts.")
local ttt_preptime_seconds = CreateConVar("ttt_preptime_seconds", "5", FCVAR_NONE, "The wait time before any round besides the first starts.")
local ttt_minimum_players = CreateConVar("ttt_minimum_players", "2", FCVAR_NONE, "Amount of players required before starting the round.")
local ttt_posttime_seconds = CreateConVar("ttt_posttime_seconds", "5", FCVAR_REPLICATED, "The wait time after a round has been completed.")
local ttt_roundtime_minutes = CreateConVar("ttt_roundtime_minutes", "10", FCVAR_REPLICATED, "The maximum length of a round.")

local ttt_haste = CreateConVar("ttt_haste", "1", FCVAR_REPLICATED, "Enables haste mode. Haste mode has a small initial time with additional time for each kill.")
local ttt_haste_starting_minutes = CreateConVar("ttt_haste_starting_minutes", "5", FCVAR_REPLICATED, "The initial time limit before kill time is added.")
local ttt_haste_minutes_per_death = CreateConVar("ttt_haste_minutes_per_death", "0.5", FCVAR_REPLICATED, "The time added in minutes per death in haste mode.")

ttt.ActivePlayers = ttt.ActivePlayers or {}
round = round or {
	FirstRound = true,
	Players = {
		--[[
			{
				Player = entity,
				Nick = string,
				SteamID = string
			}
		]]
	},
	Started = {},
	CurrentePromise = nil
}

AccessorFunc(ttt, "RealRoundEndTime", "RoundEndTime")

function round.SetRoundEndTime(time)
	ttt.SetRealRoundEndTime(time)

	if (timer.Exists "TTTRoundStatePromise") then
		local promise = round.CurrentPromise
		timer.Create("TTTRoundStatePromise", time - CurTime(), 1, function()
			if (promise["then"]) then
				promise["then"](state, time)
			else
				warn("no then found for roundstate %s\n", ttt.Enums.RoundState[state])
			end
		end)
	end
end

function round.SetState(state, time)
	ttt.SetRoundState(state)
	ttt.SetRoundStateChangeTime(CurTime())
	ttt.SetVisibleRoundEndTime(CurTime() + time)
	round.SetRoundEndTime(ttt.GetVisibleRoundEndTime())
	local prom = round.CurrentPromise

	if (prom) then
		timer.Remove("TTTRoundStatePromise")

		if (prom["fail"]) then
			prom["fail"](state, time)
		end
	end

	local promise = {
		_fail = function(self, fn)
			self["fail"] = fn
			return self
		end,
		_then = function(self, fn)
			self["then"] = fn
			return self
		end,
	}

	round.CurrentPromise = promise

	if (time) then
		timer.Create("TTTRoundStatePromise", time, 1, function()
			if (promise["then"]) then
				promise["then"](state, time)
			else
				warn("no then found for roundstate %s\n", ttt.Enums.RoundState[state])
			end
		end)
	end

	return promise
end

function round.GetActivePlayers()
	return round.Players
end

function round.GetStartingPlayers()
	return round.Started
end

function round.GetActivePlayersByRole(roleteam)
	local ret = {}
	for _, ply in pairs(round.GetActivePlayers()) do
		if (ply.Role.Name == roleteam or ply.Role.Team.Name == roleteam) then
			ret[#ret + 1] = ply.Player
		end
	end

	return ret
end

function round.IsPlayerActive(ply)
	local plys = round.GetActivePlayers()
	for _, active in pairs(plys) do
		if (ply == active.Player) then
			return true
		end
	end

	return false
end

function round.RemovePlayer(ply)
	local plys = round.GetActivePlayers()
	for i, active in pairs(plys) do
		if (ply == active.Player) then
			table.remove(plys, i)
			hook.Run("TTTPlayerRemoved", ply)
			if (ttt_haste:GetBool() and ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
				round.SetRoundEndTime(ttt.GetRealRoundEndTime() + ttt_haste_minutes_per_death:GetFloat() * 60)
			end
			return true
		end
	end

	return false
end

function round.Prepare()
	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_WAITING and ttt.GetRoundState() ~= ttt.ROUNDSTATE_ENDED) then
		return
	end

	round.SetState(ttt.ROUNDSTATE_PREPARING, 0):_then(function()
		local eligible = ttt.GetEligiblePlayers()
		for _, ply in pairs(eligible) do
			ply:StripAmmo()
			ply:StripWeapons()
			ply:Spawn()
			ply:SetHealth(ply:GetMaxHealth())
			printf("%s <%s> has been respawned", ply:Nick(), ply:SteamID())
		end

		for _, oply in pairs(player.GetAll()) do
			if (not table.HasValue(eligible, oply)) then
				oply:KillSilent()
			end
		end

		round.SetState(ttt.ROUNDSTATE_PREPARING, (round.FirstRound and ttt_firstpreptime or ttt_preptime_seconds):GetFloat()):_then(round.TryStart)
	end)
end

function round.TryStart()
	local plys = ttt.GetEligiblePlayers()
	if (#plys < ttt_minimum_players:GetInt()) then
		round.SetState(ttt.ROUNDSTATE_WAITING, 0)
		return false
	end

	for _, oply in pairs(player.GetAll()) do
		if (not table.HasValue(plys, oply)) then
			oply:KillSilent()
		end
	end

	local roles_needed = {}

	for role, info in pairs(ttt.roles) do
		if (info.CalculateAmount) then
			roles_needed[role] = info.CalculateAmount(#plys)
			if (roles_needed[role] == 0) then
				roles_needed[role] = nil
			end
		end
	end

	round.Players = {}
	local randPlayers = table.Copy(plys)
	for i, ply in pairs(randPlayers) do
		randPlayers[i] = {
			Player = ply,
			Tickets = math.random() * ply.Tickets
		}
	end
	table.sort(randPlayers, function(a, b)
		return a.Tickets > b.Tickets
	end)
	for i, info in ipairs(randPlayers) do
		local ply = info.Player
		local role, amt = next(roles_needed)
		if (role) then
			if (amt == 1) then
				roles_needed[role] = nil
			else
				roles_needed[role] = amt - 1
			end
		else
			role = "Innocent"
		end

		round.Players[i] = {
			Player = ply,
			SteamID = ply:SteamID(),
			Nick = ply:Nick(),
			Role = ttt.roles[role]
		}
	end

	if (not hook.Run("TTTRoundStart", plys)) then
		printf("Round state is %i and failed to start round", ttt.GetRoundState())
		round.SetState(ttt.ROUNDSTATE_WAITING, 0)
		return false
	end

	round.Started = table.Copy(round.Players)

	printf("Round state is %i, we have enough players at %i, starting game", ttt.GetRoundState(), #plys)
	-- TODO(meep): setup variables

	round.SetState(ttt.ROUNDSTATE_ACTIVE, (ttt_haste:GetBool() and ttt_haste_starting_minutes or ttt_roundtime_minutes):GetFloat() * 60):_then(function()
		local winners = {}

		for _, ply in pairs(round.GetStartingPlayers()) do
			if (ply.Role.Team.Name == "innocent") then
				table.insert(winners, ply)
			end
		end

		round.End("innocent", winners)
	end)
	round.FirstRound = false
	return true
end

function round.End(winning_team, winners)
	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
		warn("round.End called when ROUNDSTATE = %i\n", ttt.GetRoundState())
		return
	end
	hook.Run("TTTRoundEnd", winning_team, winners)
end

function GM:OnPlayerRoleChange(ply, old, new)
	local role = ttt.roles[new]

	for _, info in pairs(round.GetActivePlayers()) do
		if (info.Player == ply) then
			info.Role = role
		end
	end

	for _, info in pairs(round.GetStartingPlayers()) do
		if (info.Player == ply) then
			info.Role = role
		end
	end

	ttt.CheckTeamWin()
end

function GM:ProvideRoleGuns(ply)
	for _, wep in pairs(weapons.GetList()) do
		if (wep.InLoadout and (wep.InLoadout[ply:GetRole()] or wep.InLoadout[ply:GetRoleTeam()])) then
			ply:Give(wep.ClassName)
		end
	end
end

function GM:TTTRoundStart()
	for _, info in pairs(round.GetActivePlayers()) do
		if (IsValid(info.Player)) then
			info.Player:ChatPrint("Your role is "..info.Role.Name.." on team "..info.Role.Team.Name)
			info.Player:SetRole(info.Role.Name)
			info.Player:SetCredits(info.Player:GetRoleData().DefaultCredits or 0)
			self:ProvideRoleGuns(info.Player)
			info.Player:SetTeam(TEAM_TERROR)
			info.Player:SetConfirmed(false)

			if (info.Role.ModifyTickets) then
				info.Player.Tickets = info.Role.ModifyTickets(info.Player.Tickets)
			else
				info.Player.Tickets = info.Player.Tickets + 1
			end
		end
		if (not info.Player:Alive()) then
			info.Player:Spawn()
		end
	end

	return true
end

function GM:TTTBeginRound()
	self:MapVote_TTTBeginRound()
	for _, info in pairs(round.GetActivePlayers()) do
		if (not IsValid(info.Player)) then
			continue
		end

		info.Player:SetHealth(info.Player:GetMaxHealth())
		info.Player:Extinguish()
	end

	for _, ent in pairs(ents.GetAll()) do
		if (ent.Cleanup) then
			ent:Remove()
		end
	end
end

util.AddNetworkString "ttt_endround"

function GM:TTTRoundEnd(winning_team, winners)
	local winner_names = {}
	local winner_ents  = {}

	for _, ply in pairs(winners) do
		table.insert(winner_names, ply.Nick)
		table.insert(winner_ents, ply.Player)
	end

	net.Start "ttt_endround"
		net.WriteString(winning_team)
		net.WriteUInt(#winner_names, 8)
		for i = 1, #winner_names do
			net.WriteString(winner_names[i])
		end
	net.Broadcast()

	round.SetState(ttt.ROUNDSTATE_ENDED, ttt_posttime_seconds:GetFloat()):_then(round.Prepare)
end

function GM:PlayerInitialSpawn(ply)
	player_manager.SetPlayerClass(ply, "player_terror")
	self:Karma_PlayerInitialSpawn(ply)

	local state = ents.Create "ttt_hidden_info"
	state:SetParent(ply)
	state:Spawn()
	
	ply:AllowFlashlight(true)
	ply:SetTeam(TEAM_SPECTATOR)
	ply.Tickets = 1

	local should, reason = hook.Run "ShouldChangeMap"

	if (player.GetCount() == 1 and should) then
		game.LoadNextMap(reason)
	end
end

function GM:SV_PlayerSpawn(ply)
	ply.Killed = {}
	local state = ttt.GetRoundState()

	if (state == ttt.ROUNDSTATE_WAITING) then
		round.Prepare()
	elseif (state ~= ttt.ROUNDSTATE_PREPARING) then
		printf("Player %s <%s> joined while round is active, killing silently", ply:Nick(), ply:SteamID())
		ply:KillSilent()
		-- TODO(meep): make spectator code
		return
	end

	ply:UnSpectate()

	hook.Run("PlayerLoadout", ply)
	hook.Run("PlayerSetModel", ply)

	local Role = ttt.roles[ply:GetRole()]

	hook.Run("PlayerSetSpeed", ply, Role.Speed, Role.RunSpeed)
end

function GM:PlayerSetSpeed(ply, walkspeed, runspeed)
	ply:SetWalkSpeed(walkspeed)
	ply:SetCrouchedWalkSpeed(0.2)
	ply:SetRunSpeed(runspeed or walkspeed)
end

function GM:PlayerDisconnected(ply)
	if (round.RemovePlayer(ply)) then
		printf("Player %s <%s> has disconnected while round is active", ply:Nick(), ply:SteamID())
		hook.Run("TTTActivePlayerDisconnected", ply)
	else
		printf("Player %s <%s> has disconnected", ply:Nick(), ply:SteamID())
	end

	self:Karma_PlayerDisconnected(ply)
end

function GM:TTTHasRoundBeenWon(plys, roles)
	if (roles.innocent == 0) then
		return true, "traitor"
	end
	if (roles.traitor == 0) then
		return true, "innocent"
	end

	return false
end

function ttt.CheckTeamWin()
	local plys = round.GetActivePlayers()

	local roles = {}
	for team in pairs(ttt.teams) do
		roles[team] = 0
	end

	for _, ply in pairs(plys) do
		local team = ply.Role.Team.Name
		roles[team] = roles[team] + 1
	end

	local has_won, win_team, time_ran_out = hook.Run("TTTHasRoundBeenWon", plys, roles)

	if (has_won) then
		printf("Round has been won, team: %s, time limit reached: %s", win_team, time_ran_out and "true" or "false")

		local winners = {}

		for _, ply in pairs(round.GetStartingPlayers()) do
			if (ply.Role.Team.Name == win_team) then
				table.insert(winners, ply)
			end
		end

		round.End(win_team, winners)
	end
end

function GM:TTTPlayerRemoved(removed)
	if (IsValid(removed)) then
		-- removed:SetRole "Spectator"
	end

	timer.Simple(0, function()
		if (IsValid(removed)) then
			self:TTTPlayerRemoveSpectate(removed)
		end

		ttt.CheckTeamWin()
	end)
end

function GM:PlayerDeath(ply)
	round.RemovePlayer(ply)
	ply:Extinguish()
end