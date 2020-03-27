local ttt_traitor_max = CreateConVar("ttt_traitor_max", "32", FCVAR_REPLICATED, "The max amount of traitors in a round.")
local ttt_traitor_pct = CreateConVar("ttt_traitor_pct", "0.25", FCVAR_REPLICATED, "The percent of players that will be traitors.")
local ttt_detective_pct = CreateConVar("ttt_detective_pct", "0.13", FCVAR_REPLICATED, "The percent of players that will be detectives.")
local ttt_detective_max = CreateConVar("ttt_detective_max", "32", FCVAR_REPLICATED, "The max amount of detectives in a round.")
local ttt_detective_min_players = CreateConVar("ttt_detective_min_players", "10", FCVAR_REPLICATED, "The amount of players needed before detectives spawn.")

local TEAM = {}

function ttt.CanPlayerSeePlayersRole(looker, ply)
	local SeenBy = ply:GetRoleData().CanBeSeenBy
	local TeamSeenBy = ply:GetRoleTeamData().CanBeSeenBy
	if (SeenBy) then
		if (SeenBy[looker:GetRole()] or SeenBy[looker:GetRoleTeam()] or SeenBy["*"]) then
			return true
		end
	end

	if (TeamSeenBy and TeamSeenBy ~= SeenBy) then
		if (TeamSeenBy[looker:GetRole()] or TeamSeenBy[looker:GetRoleTeam()] or TeamSeenBy["*"]) then
			return true
		end
	end

	return false
end

local function AccessorFunc(self, name, fnname)
	fnname = fnname or name
	self["Get" .. fnname] = function(self)
		return self[name]
	end

	self["Set" .. fnname] = function(self, v)
		self[name] = v
		return self
	end
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
	self.CanBeSeenBy = setmetatable({}, SEEN_BY_ALL)
	return self
end

function TEAM:SeenBy(what)
	if (not self.CanBeSeenBy) then
		self.CanBeSeenBy = {}
	end

	if (type(what) ~= "table") then
		what = {what}
	end

	for _, what in ipairs(what) do
		self.CanBeSeenBy[what] = true
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

function TEAM:CreditOnRoleDeath(func)
	self.OnRoleDeath = func
	return self
end

AccessorFunc(TEAM, "ModifyTickets", "ModifyTicketsFunc")
AccessorFunc(TEAM, "Evil")
AccessorFunc(TEAM, "CanUseBuyMenu")
AccessorFunc(TEAM, "VoiceChannel")
AccessorFunc(TEAM, "DeathIcon")
AccessorFunc(TEAM, "DefaultCredits")
AccessorFunc(TEAM, "CalculateAmount", "CalculateAmountFunc")

setmetatable(SEEN_BY_ALL, SEEN_BY_ALL)

local ROLE = {
	SetColor = TEAM.SetColor,
	SeenBy = TEAM.CanBeSeenBy,
	SeenByAll = TEAM.CanBeSeenByAll
}

local TEAM_MT = {
	__index = TEAM
}

local function Team(name)
	local t = ttt.teams[name] or setmetatable({
		Name = name,
		Speed = 260,
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
	Team "innocent"
		:SetColor(56, 172, 87)
		:SetDeathIcon "materials/tttrw/roles/innocent.png"

	Team "traitor"
		:SeenBy {"traitor"}
		:SetColor(Color(175, 47, 36))
		:SetDefaultCredits(2)
		:CreditOnRoleDeath(function(roles, deathrole)
			if (deathrole.Team == "traitor") then
				return 0
			end

			local amt = 0

			for role, i in pairs(roles) do
				if (role.Team.Name ~= "traitor") then
					amt = amt + i
				end
			end

			return amt % 4 == 0 and 1 or 0
		end)
		:TeamChatSeenBy "traitor"
		:SetVoiceChannel "traitor"
		:SetEvil(true)
		:SetCanUseBuyMenu(true)
		:SetDeathIcon "materials/tttrw/tbutton.png"
		:SetModifyTicketsFunc(function(tickets)
			return tickets / 2
		end)

	Team "spectator"
		:SeenByAll()
		:SetColor(Color(51, 54, 56))

	Role("Innocent", "innocent")
	Role("Spectator", "spectator")
	Role("Detective", "innocent")
		:SeenByAll()
		:SetCalculateAmountFunc(function(total_players)
			return math.floor(math.Clamp(total_players * ttt_detective_pct:GetFloat(), 0, ttt_detective_max:GetInt()))
		end)
		:SetColor(56, 80, 210)
		:TeamChatSeenBy "Detective"
		:SetVoiceChannel "Detective"
		:SetCanUseBuyMenu(true)
		:SetModifyTicketsFunc(function(tickets)
			return tickets - 1
		end)
		:SetDeathIcon "materials/tttrw/roles/detective.png"
		:SetDefaultCredits(2)
		:CreditOnRoleDeath(function(roles, deathrole)
			if (not deathrole.IsEvil) then
				return 0
			end

			local amt = 0

			for role, i in pairs(roles) do
				if (role.IsEvil) then
					amt = amt + i
				end
			end

			return amt % 3 == 0 and 1 or 0
		end)

	Role("Traitor", "traitor")
		:SetCalculateAmountFunc(function(total_players)
			return math.floor(math.Clamp(total_players * ttt_traitor_pct:GetFloat(), 1, ttt_traitor_max:GetInt()))
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
	table.insert(vars, {
		Name = "Credits",
		Type = "Int",
		Default = 0,
		Enums = {}
	})
end)

local PLY = FindMetaTable "Player"

function PLY:GetRoleData()
	return ttt.roles[self:GetRole()]
end

function PLY:GetRoleTeamData()
	return ttt.roles[self:GetRole()].Team
end

function PLY:GetRoleTeam()
	return ttt.roles[self:GetRole()].Team.Name
end