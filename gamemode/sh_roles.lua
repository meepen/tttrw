local ttt_traitor_max = CreateConVar("ttt_traitor_max", "32", FCVAR_REPLICATED, "The max amount of traitors in a round.")
local ttt_traitor_pct = CreateConVar("ttt_traitor_pct", "0.25", FCVAR_REPLICATED, "The percent of players that will be traitors.")
local ttt_detective_pct = CreateConVar("ttt_detective_pct ", "0.13", FCVAR_REPLICATED, "The percent of players that will be detectives.")
local ttt_detective_max = CreateConVar("ttt_detective_max", "32", FCVAR_REPLICATED, "The max amount of detectives in a round.")
local ttt_detective_min_players = CreateConVar("ttt_detective_min_players", "10", FCVAR_REPLICATED, "The amount of players needed before detectives spawn.")

local TEAM = {}

function TEAM:SetColor(col, g, b, a)
	if (type(col) == "number") then
		col = Color(col, g, b, a)
	end

	self.Color = col
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

local SEEN_BY_ALL = {
	__index = function() return true end,
	__newindex = function() end,
	__eq = function() return true end
}

setmetatable(SEEN_BY_ALL, SEEN_BY_ALL)

function TEAM:SeenByAll()
	self.CanBeSeenBy = setmetatable({}, SEEN_BY_ALL)
	return self
end

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
		Name = name
	}, TEAM_MT)

	ttt.teams[name] = t

	return t
end

local ROLE_MT = {
	__index = ROLE
}

local function Role(name, team)
	local role = ttt.roles[name] or setmetatable({
		Name = name,
		Team = team
	}, ROLE_MT)

	ttt.roles[name] = role

	return role
end

function GM:SetupRoles()
	ttt.roles = {}
	ttt.teams = {}

	Team "innocent":SetColor(Color(20, 240, 20))
	Team "traitor":SeenBy {"traitor"}:SetColor(Color(240, 20, 20))
	Team "spectator":SeenByAll():SetColor(Color(20, 120, 120))

	Role("Innocent", "innocent")
	Role("Spectator", "spectator")
	Role("Detective", "innocent"):SeenByAll():SetCalculateAmountFunction(function(total_players)
		if (ttt_detective_min_players:GetFloat() > total_players) then
			return 0
		end
		return math.min(ttt_detective_max:GetInt(), math.ceil(total_players * ttt_detective_pct:GetFloat()))
	end):SetColor(20, 20, 240)
	Role("Traitor", "traitor"):SetCalculateAmountFunction(function(total_players)
		return math.min(ttt_traitor_max:GetInt(), math.ceil(total_players * ttt_traitor_pct:GetFloat()))
	end)

	hook.Run("TTTPrepareRoles", Team, Role)

	for name, role in pairs(ttt.roles) do
		local team = ttt.teams[role.Team]

		-- merge SeenBy

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
			role.Color = team.Color or color_black
		end
	end


	-- TODO(meep): merge team data into role data for everything
end
