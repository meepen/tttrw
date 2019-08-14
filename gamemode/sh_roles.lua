local ttt_traitor_max = CreateConVar("ttt_traitor_max", "32", FCVAR_REPLICATED, "The max amount of traitors in a round.")
local ttt_traitor_pct = CreateConVar("ttt_traitor_pct", "0.25", FCVAR_REPLICATED, "The percent of players that will be traitors.")
local ttt_detective_pct = CreateConVar("ttt_detective_pct ", "0.13", FCVAR_REPLICATED, "The percent of players that will be detectives.")
local ttt_detective_max = CreateConVar("ttt_detective_max", "32", FCVAR_REPLICATED, "The max amount of detectives in a round.")
local ttt_detective_min_players = CreateConVar("ttt_detective_min_players", "10", FCVAR_REPLICATED, "The amount of players needed before detectives spawn.")

local TEAM = {}

ttt.SeenBy = ttt.SeenBy or {}


function ttt.CanPlayerSeePlayersRole(looker, ply)
	local r, t = ply:GetRole()
	t = ttt.roles[r].Team.Name

	r, t = ttt.SeenBy[r], ttt.SeenBy[t]

	local lr, lt = looker:GetRole()
	lt = ttt.roles[lr].Team.Name

	if (r and (r[lr] or r[lt])) then
		return true
	end
	if (t and (t[lr] or t[lt])) then
		return true
	end
	
	return false
end

function TEAM:SetColor(col, g, b, a)
	if (type(col) == "number") then
		col = Color(col, g, b, a)
	end

	self.Color = col
	return self
end

local SEEN_BY_ALL = {
	__index = function() return true end,
	__newindex = function() end,
	__eq = function() return true end
}

function TEAM:SeenByAll()
	ttt.SeenBy[self.Name] = setmetatable({}, SEEN_BY_ALL)
	return self
end

function TEAM:SeenBy(what)
	if (not ttt.SeenBy[self.Name]) then
		ttt.SeenBy[self.Name] = {}
	end

	if (type(what) ~= "table") then
		what = {what}
	end

	for _, what in ipairs(what) do
		ttt.SeenBy[self.Name][what] = true
	end

	return self
end

function TEAM:TeamChatSeenBy(what)
	if (not self.TeamChatCanBeSeenBy) then
		self.TeamChatCanBeSeenBy = {}
	end

	if (type(what) ~= "table") then
		what = {what}
	end

	for _, what in ipairs(what) do
		self.TeamChatCanBeSeenBy[what] = true
	end

	return self
end

function TEAM:SetVoiceChannel(channel)
	self.VoiceChannel = channel
end

setmetatable(SEEN_BY_ALL, SEEN_BY_ALL)

local ROLE = {
	SetColor = TEAM.SetColor,
	SeenBy = TEAM.SeenBy,
	SeenByAll = TEAM.SeenByAll
}

function ROLE:SetCalculateAmountFunction(fn)
	self.CalculateAmount = fn
	return self
end

local TEAM_MT = {
	__index = TEAM
}

local function Team(name)
	local t = ttt.teams[name] or setmetatable({
		Name = name,
		Speed = 300,
		--[[
		RunSpeed = 400,
		RunTime = 3, -- seconds
		RunRecovery = 0.5, -- per second
		RunMinimum = 0.5 -- before running you have to have this amount of a fraction
		]]
	}, TEAM_MT)

	ttt.teams[name] = t

	return t
end

local ROLE_MT = {
	__index = function(self, index)
		local Team = rawget(self, "Team")
		if (Team and Team[index]) then
			return Team[index]
		end
		return ROLE[index]
	end
}

local function Role(name, team)
	local role = ttt.roles[name] or setmetatable({
		Name = name,
		Team = Team(team)
	}, ROLE_MT)

	ttt.roles[name] = role

	return role
end

function GM:TTTPrepareRoles(Team, Role)
	Team "innocent":SetColor(Color(20, 240, 20))
	Team "traitor":SeenBy {"traitor"}:SetColor(Color(240, 20, 20)):TeamChatSeenBy "traitor" :SetVoiceChannel "traitor"
	Team "spectator":SeenByAll():SetColor(Color(20, 120, 120))

	Role("Innocent", "innocent")
	Role("Spectator", "spectator")
	Role("Detective", "innocent"):SeenByAll():SetCalculateAmountFunction(function(total_players)
		if (ttt_detective_min_players:GetFloat() > total_players) then
			return 0
		end
		return math.min(ttt_detective_max:GetInt(), math.ceil(total_players * ttt_detective_pct:GetFloat()))
	end):SetColor(20, 20, 240):TeamChatSeenBy "Detective" :SetVoiceChannel "Detective"
	Role("Traitor", "traitor"):SetCalculateAmountFunction(function(total_players)
		return math.min(ttt_traitor_max:GetInt(), math.ceil(total_players * ttt_traitor_pct:GetFloat()))
	end)
end

function GM:SetupRoles()
	ttt.roles = {}
	ttt.teams = {}

	hook.Run("TTTPrepareRoles", Team, Role)

	for name, role in pairs(ttt.roles) do
		local team = role.Team

		if (team.CanBeSeenBy) then
			if (not role.CanBeSeenBy or team.CanBeSeenBy == SEEN_BY_ALL) then
				role.CanBeSeenBy = team.CanBeSeenBy
			else
				for what in pairs(team.CanBeSeenBy) do
					role.CanBeSeenBy[what] = true
				end
			end
		end

		if (not role.Color) then
			role.Color = color_black
		end
	end
end

hook.Add("TTTGetHiddenPlayerVariables", "Roles", function(vars)
	table.insert(vars, {
		Name = "Role",
		Type = "String",
		Default = "Spectator",
		Enums = {}
	})
end)

local PLY = FindMetaTable "Player"

function PLY:GetRoleData()
	return ttt.roles[self:GetRole()]
end

function PLY:GetTeamData()
	return ttt.roles[self:GetRole()].Team
end

function PLY:GetTeam()
	return ttt.roles[self:GetRole()].Team.Name
end