DEFINE_BASECLASS "player_default"

local PLAYER = {}

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 200

TEAM_TERROR = 1
team.SetUp(TEAM_TERROR, "Terrorist", color_white, false)

function PLAYER:Loadout()
	local ply = self.Player
	ply:StripAmmo()
	ply:StripWeapons()
	
	-- TODO(meep): should we do something else here???
end

function PLAYER:Spawn()
	if (SERVER) then
		self.Player:SetupHands()
	end
end

function PLAYER:SetupDataTables()
	local ply = self.Player

	-- TODO(meep): make hook here
end

function PLAYER:GetSpeedData()
	local ply = self.Player
	local wep = ply:GetActiveWeapon()

	local data = {
		Multiplier = 1,
		FinalMultiplier = IsValid(wep) and wep.GetIronsights and wep:GetIronsights() and wep.Ironsights and wep.Ironsights.SlowDown or 1
	}

	hook.Run("TTTUpdatePlayerSpeed", data)

	return data
end

function PLAYER:Think()
end

function PLAYER:StartCommand()
end

player_manager.RegisterClass("player_terror", PLAYER, "player_default")