DEFINE_BASECLASS "player_default"

local PLAYER = {}

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 200

function PLAYER:Loadout()
	local ply = self.Player
	ply:StripAmmo()
	ply:StripWeapons()

	hook.Run("TTTPlayerGiveWeapons", ply)

	ply:Give "weapon_ttt_crowbar"
	ply:Give "weapon_ttt_unarmed"
	ply:Give "weapon_ttt_magneto"
end

function PLAYER:Spawn()
	self.Player:SetJumpPower(160)
	if (SERVER) then
		self.Player:SetupHands(self.Player)
	end
end

function PLAYER:SetupDataTables()
	local ply = self.Player

	local fake = {
		NetworkVar = function(self, name, type)
			local list = self.list[type]
			if (not list) then
				list = {}
				self.list[type] = list
			end

			list[#list + 1] = {
				Name = name,
				Type = type
			}
		end,
		list = {},
		Player = ply
	}

	fake:NetworkVar("Confirmed", "Bool")
	fake:NetworkVar("Karma", "Int")
	fake:NetworkVar("HealthFloat", "Float")
	fake:NetworkVar("DucksInRow", "Int")
	fake:NetworkVar("LastDuck", "Float")

	hook.Run("SetupPlayerNetworking", fake)

	table.sort(fake, function(a, b) return a[1] < b[1] end)

	for type, list in pairs(fake.list) do
		for num, data in ipairs(list) do
			self.Player:NetworkVar(data.Type, num, data.Name)
		end
	end
end

function PLAYER:GetSpeedData()
	local ply = self.Player
	local wep = ply:GetActiveWeapon()

	local data = {
		Multiplier = 1,
		FinalMultiplier = IsValid(wep) and wep.GetIronsights and wep:GetIronsights() and wep.Ironsights and wep.Ironsights.SlowDown or 1
	}

	hook.Run("TTTUpdatePlayerSpeed", ply, data)

	return data
end

function PLAYER:Think()
end

function PLAYER:StartCommand()
end

player_manager.RegisterClass("player_terror", PLAYER, "player_default")