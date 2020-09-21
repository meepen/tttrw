util.AddNetworkString "ttt_player_target"

net.Receive("ttt_player_target", function(len, cl)
	local ent = net.ReadEntity()

	if (IsValid(ent) and (ent:IsPlayer() or ent:GetNW2Bool("IsPlayerBody", false))) then
		cl:SetTarget(ent)
	end
	timer.Create("EliminateTargetFor" .. cl:UserID(), 3, 1, function()
		if (IsValid(cl)) then
			cl:SetTarget(nil)
		end
	end)
end)

function GM:TTTShouldChangeMap()
	if (self.ShouldRTV) then
		return true, "Vote has been rocked"
	end

	return false
end

function GM:AllowPlayerRTV(ply)
	if (self.RTV and self.RTV[ply]) then
		return false, "You've already RTVed", true
	end

	return ttt.GetRoundNumber() >= 2, "Wait for " .. (3 - ttt.GetRoundNumber()) .. " rounds"
end

function GM:PlayerRTVFailed(ply, reason)
	ply:ChatPrint("Cannot RTV: " .. reason)
end

function GM:DoPlayerRTV(ply, remaining)
	local data = {ttt.teams.innocent.Color, ply:Nick(), white_text, " has voted to change the map ("}
	if (remaining > 0) then
		data[#data + 1] = ttt.teams.traitor.Color
		data[#data + 1] = tostring(remaining)
		data[#data + 1] = white_text
		data[#data + 1] = " votes remaining)"
	else
		data[#data + 1] = ttt.teams.innocent.Color
		data[#data + 1] = "Vote limit reached, map will change!"
		data[#data + 1] = white_text
		data[#data + 1] = ")"
	end
	ttt.chat(unpack(data))
end

function GM:MapHasBeenRTVed()
end

function GM:PlayerSay(ply, text, team)
	if (text:match "^[!%./]?rtv$") then
		local allow, reason, noprevent = hook.Run("AllowPlayerRTV", ply)

		if (not allow) then
			hook.Run("PlayerRTVFailed", ply, reason)
			if (not noprevent) then
				return ""
			end
		else
			self.RTV = self.RTV or {}
			self.RTV[ply] = true
		
			local votes = 0
			for ply in pairs(self.RTV) do
				if (IsValid(ply)) then
					votes = votes + 1
				end
			end
		
			local needed = math.max(1, math.floor(player.GetCount() * 3 / 4))
		
			if (needed <= votes) then
				self.ShouldRTV = true
				hook.Run "MapHasBeenRTVed"
			end

			hook.Run("DoPlayerRTV", ply, needed - votes)

			return ""
		end
	end

	if (team and (not ply:Alive() or ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE or not ply:GetRoleData().TeamChatCanBeSeenBy)) then
		ply:Say(text, false)

		return ""
	end

	local text, amount = hook.Run("FormatPlayerText", ply, text)

	ply.Formatted = amount ~= 0

	return text
end

function GM:PlayerCanSeePlayersChat(text, team, listener, speaker)
	if (not IsValid(speaker)) then
		-- console

		return true
	end

	if (listener:Alive() and not speaker:Alive() and ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
		return false
	end

	if (team) then
		local lr = speaker:GetRoleData()

		if (not lr.TeamChatCanBeSeenBy) then
			return false
		end
		
		if (not lr.TeamChatCanBeSeenBy[listener:GetRole()] and not lr.TeamChatCanBeSeenBy[listener:GetRoleTeam()]) then
			return false
		end
	end

	return true
end

local function GetPlayersWhoHear(ply)
	local plys = player.GetAll()
	for i = #plys, 1, -1 do
		if not (hook.Run("PlayerCanHearPlayersVoice", plys[i], ply)) then
			table.remove(plys, i)
		end
	end

	return plys
end

local SoundStates = {
	{
		Name = "Mute None",
		Query = function(hear, talk)
			return true
		end,
	},
	{
		Name = "Mute Living",
		Query = function(hear, talk)
			return not talk:Alive()
		end,
	},
	{
		Name = "Mute All",
		Query = function(hear, talk)
			return false
		end,
	}
}

local function GetSoundState(ply)
	return SoundStates[(ply.SoundState or 0) + 1]
end

local function AbleToHear(hear, talk)
	local t_alive, h_alive = talk:Alive(), hear:Alive()
	local able = false
	if (not t_alive and h_alive) then
		return false
	elseif (not t_alive and not h_alive or not talk:KeyDown(IN_SPEED)) then
		able = true
	else
		local channel = talk:GetRoleData().VoiceChannel

		able = not channel or hear:GetRoleData().VoiceChannel ==  channel
	end

	return able
end

local cache = setmetatable({}, {__index = function() return {} end})

local function TTTRWUpdateVoiceState(ply, hearing)
	for _, _ply in pairs(player.GetAll()) do
		local hear = hearing and ply or _ply
		local talk = hearing and _ply or ply

		local able = AbleToHear(hear, talk)

		if (able and not hear:Alive()) then
			local state = GetSoundState(hear)

			able = state.Query(hear, talk)
		end

		cache[hear][talk] = able
	end
	hook.Run("TTTRWUpdateVoiceState", hear, cache[hear])
end

timer.Create("tttrw_hear_player_cache", 0.5, 0, function()
	for _, hear in pairs(player.GetAll()) do
		if (not rawget(cache, hear)) then
			cache[hear] = {}
		end
		TTTRWUpdateVoiceState(hear, true)
	end
end)

util.AddNetworkString "ttt_voice"

function GM:VoiceKey(ply, key)
	if (key == IN_SPEED) then
		TTTRWUpdateVoiceState(ply, false)
		net.Start "ttt_voice"
			net.WriteBool(true)
			net.WriteEntity(ply)
		net.Send(GetPlayersWhoHear(ply))
	end
end

function GM:KeyRelease(ply, key)
	if (key == IN_SPEED) then
		TTTRWUpdateVoiceState(ply, false)
		net.Start "ttt_voice"
			net.WriteBool(false)
			net.WriteEntity(ply)
		net.Send(GetPlayersWhoHear(ply))
	end
end

function GM:PlayerCanHearPlayersVoice(hear, talk)
	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
		return true, false
	end

	return cache[hear][talk], false
end

function GM:ShowTeam(p)
	p.SoundState = ((p.SoundState or 0) + 1) % #SoundStates
	p:ChatPrint("Voice state set to: " .. GetSoundState(p).Name)
end