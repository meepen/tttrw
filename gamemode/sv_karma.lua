local ttt_karma = CreateConVar("ttt_karma", "1", FCVAR_NONE, "Enables the karma system.")
local ttt_karma_starting = CreateConVar("ttt_karma_starting", "1000", FCVAR_NONE, "Starting karma")
local ttt_karma_max = CreateConVar("ttt_karma_max", "1000", FCVAR_NONE, "Max Karma a player can have.")
local ttt_karma_round_increment = CreateConVar("ttt_karma_round_increment", "5", FCVAR_NONE, "Karma is healed at this every round")
local ttt_karma_clean_half = CreateConVar("ttt_karma_clean_half", "0.25")
local ttt_karma_clean_bonus = CreateConVar("ttt_karma_clean_bonus", "30")
local ttt_karma_traitordmg_ratio = CreateConVar("ttt_karma_traitordmg_ratio", "0.0003")
local ttt_karma_kill_penalty = CreateConVar("ttt_karma_kill_penalty", "15")
local ttt_karma_strict = CreateConVar("ttt_karma_strict", "1")
local ttt_karma_traitorkill_bonus = CreateConVar("ttt_karma_traitorkill_bonus", "40")

local expdecay = math.ExponentialDecay
local function DecayedMultiplier(ply)
	local max   = ttt_karma_max:GetInt()
	local start = ttt_karma_starting:GetInt()
	local k     = ply:GetKarma()

	if (ttt_karma_clean_half:GetInt() <= 0 or k < start) then
		return 1
	elseif (k < max) then
		-- if falloff is enabled, then if our karma is above the starting value,
		-- our round bonus is going to start decreasing as our karma increases
		local basediff = max - start
		local plydiff  = k - start
		local half     = math.Clamp(ttt_karma_clean_half:GetFloat(), 0.01, 0.99)

		-- exponentially decay the bonus such that when the player's excess karma
		-- is at (basediff * half) the bonus is half of the original value
		return expdecay(basediff * half, plydiff)
	end

	return 1
end

local function GiveReward(ply, reward)
   reward = DecayedMultiplier(ply) * reward
   ply:SetKarma(math.min(ply:GetKarma() + reward, ttt_karma_max:GetFloat()))
   return reward
end

local function GivePenalty(ply, penalty, vic)
	if (not hook.Run("TTTKarmaGivePenalty", ply, penalty, vic)) then
		ply:SetKarma(math.max(ply:GetKarma() - penalty, 0))
	end
end

local function GetHurtPenalty(victim_karma, dmg)
   return victim_karma * math.Clamp(dmg * ttt_karma_traitordmg_ratio:GetFloat(), 0, 1)
end

local function GetKillPenalty(victim_karma)
	-- the kill penalty handled like dealing a bit of damage
	return GetHurtPenalty(victim_karma, ttt_karma_kill_penalty:GetFloat())
end

local function GetHurtReward(dmg)
	return ttt_karma_max:GetFloat() * math.Clamp(dmg * ttt_karma_traitordmg_ratio:GetFloat(), 0, 1)
end

local function KarmaEnabled()
	return ttt_karma:GetBool() and ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE
end

function GM:Karma_TTTEndRound()
	if (not KarmaEnabled()) then
		return
	end

	local healbonus = ttt_karma_round_increment:GetFloat()
	local cleanbonus = ttt_karma_clean_bonus:GetFloat()

	for _, info in pairs(round.GetStartingPlayers()) do
		local ply = info.Player
		if (not IsValid(ply)) then
			continue
		end
		local bonus = healbonus -- + (ply:GetCleanRound() and cleanbonus or 0)
		GiveReward(ply, bonus)
	end
end

sql.Query "CREATE TABLE IF NOT EXISTS tttrw_karma (steamid TEXT PRIMARY KEY, karma INTEGER);"

function GM:Karma_PlayerInitialSpawn(ply)
	local val = sql.QueryValue("SELECT karma FROM tttrw_karma WHERE steamid = " .. sql.SQLStr(ply:SteamID()))

	if (not val) then
		ply:SetKarma(ttt_karma_starting:GetInt())
	else
		ply:SetKarma(val)
	end
end

function GM:ShutDown()
	local values = {}
	if (player.GetCount() == 0) then
		return
	end

	sql.Begin()
	for _, ply in pairs(player.GetAll()) do
		sql.Query("INSERT OR REPLACE INTO tttrw_karma (steamid, karma) VALUES (" .. sql.SQLStr(ply:SteamID()) .. ", " .. ply:GetKarma() .. ")")
	end
	sql.Commit()
end

function GM:Karma_PlayerDisconnected(ply)
	sql.Query("INSERT OR REPLACE INTO tttrw_karma (steamid, karma) VALUES (" .. sql.SQLStr(ply:SteamID()) .. ", " .. ply:GetKarma() .. ")")
end

function GM:Karma_DoPlayerDeath(ply, atk, dmg)
	if (not KarmaEnabled()) then
		return
	end

	if (not IsValid(atk) or not atk:IsPlayer()) then
		return
	end

	if (atk:GetRoleTeam() == ply:GetRoleTeam()) then
		local penalty = GetKillPenalty(ply:GetKarma())
  
		GivePenalty(atk, penalty, ply)

		-- TODO(meep): set not clean
	elseif (ply:GetRoleData().Evil) then
		reward = GiveReward(atk, GetHurtReward(ttt_karma_traitorkill_bonus:GetFloat()))
	end
end

function GM:Karma_EntityTakeDamage(vic, dmg)
	if (not KarmaEnabled()) then
		return
	end

	if (not IsValid(vic) or not vic:IsPlayer()) then
		return
	end

	local atk = dmg:GetAttacker()
	if (not IsValid(atk) or not atk:IsPlayer()) then
		atk = dmg:GetInflictor()
	end

	if (not IsValid(atk) or not atk:IsPlayer()) then
		return
	end

	local hurt_amount = math.min(vic:Health(), dmg:GetDamage())
	if (atk:GetRoleTeam() == vic:GetRoleTeam()) then
		local penalty = GetKillPenalty(vic:GetKarma())
  
		GivePenalty(atk, penalty, vic)

		-- TODO(meep): set not clean
	else
		local reward = GetHurtReward(hurt_amount)
		GiveReward(atk, reward)
	end
end

function GM:Karma_ScalePlayerDamage(ply, hg, dmg)
	if (not KarmaEnabled()) then
		return
	end

	if (dmg:IsDamageType(DMG_SLASH)) then
		return
	end

	local atk = dmg:GetAttacker()
	if (not IsValid(atk) or not atk:IsPlayer()) then
		atk = dmg:GetInflictor()
	end

	if (not IsValid(atk) or not atk:IsPlayer()) then
		return
	end

	local df = 1
 
	-- any karma at 1000 or over guarantees a df of 1, only when it's lower do we
	-- need the penalty curve
	if (atk:GetKarma() < 1000) then
		local k = atk:GetKarma() - 1000
		if (ttt_karma_strict:GetBool()) then
			-- this penalty curve sinks more quickly, less parabolic
			df = 1 + (0.0007 * k) + (-0.000002 * (k ^ 2))
		else
			df = 1 + -0.0000025 * (k ^ 2)
		end
	end

	dmg:ScaleDamage(math.Clamp(df, 0.1, 1.0))
end