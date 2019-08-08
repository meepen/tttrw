DEFINE_BASECLASS "player_default"

local PLAYER = {}

PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 200

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

	ply:NetworkVar("Angle", 0, "ViewPunch")
	ply:NetworkVar("Float", 0, "ViewPunchTime")
	ply:NetworkVar("Float", 1, "ViewPunchDuration")
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

local q1, quat_zero = Quaternion(), Quaternion()
quat_zero:SetEuler(Angle())

function PLAYER:Think()
end

local function GetCurrentViewPunch(ply)
	local vp, time = ply:GetViewPunch(), ply:GetViewPunchTime()
	local qvp = Quaternion()
	qvp:SetEuler(vp)

	local endtime = oldtime + 0.2
	local diff = (CurTime() - time) / 0.2
	local curvp
	if (diff < 0.5) then
		curvp = quat_zero:Lerp(qvp, diff * 2)
	end
end

function PLAYER:StartCommand(cmd)
	local ply = self.Player
	local vp = ply:GetViewPunch()
	q1:SetEuler(vp)
	q1:Lerp(quat_zero, FrameTime() * 0.1) -- TODO: not this

	--print(q1:ToEulerAngles(), q1:ToEulerAngles(), quat_zero:ToEulerAngles())
end

--[[
function PLAYER:HandleViewPunch(vp)
	local ply = self.Player
	ply:SetViewPunch(vp)
	ply:SetViewPunchTime(CurTime())
	--ply:SetViewPunchDuration()
end

FindMetaTable "Player".ViewPunch = function(self, vp)
	player_manager.RunClass(self, "HandleViewPunch", vp)
end]]

player_manager.RegisterClass("player_terror", PLAYER, "player_default")