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
	if (SERVER) then
		self.Player:SetupHands(self.Player)
	end
end

function PLAYER:SetupDataTables()
	local ply = self.Player

	self.Player:NetworkVar("Bool", 0, "Confirmed")
	self.Player:NetworkVar("Int", 0, "Karma")
	self.Player:NetworkVar("Float", 0, "HealthFloat")

	local fake = {
		NetworkVar = function(self, ...)
			self.list[#self.list + 1] = {n = select("#", ...), ...}
		end,
		list = {},
	}

	hook.Run("SetupPlayerNetworking", fake)

	table.sort(fake, function(a, b) return a[1] < b[1] end)

	for _, d in ipairs(fake) do
		self.Player:NetworkVar(unpack(d, 1, d.n))
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