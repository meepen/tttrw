include "sh_files.lua"

gameevent.Listen "player_disconnect"
gameevent.Listen "player_connect_client"
gameevent.Listen "player_spawn"

local unconnected = {}

local ttt_dna_max_time = CreateConVar("ttt_dna_max_time", "120", FCVAR_REPLICATED)

function GM:player_disconnect(info)
	hook.Run("PlayerDisconnected", Player(info.userid))
end

function GM:player_spawn(info)
	local wait = 0
	local function Do()
		local ply = Player(info.userid)
		if (not IsValid(ply)) then
			return false
		end

		if (wait == 0) then
			wait = wait + 1
			return false
		end

		timer.Remove("ttt_player_spawn_" .. info.userid)

		hook.Run("PlayerSpawn", Player(info.userid))

		return true
	end

	if (Do()) then
		return
	end
	timer.Create("ttt_player_spawn_" .. info.userid, 0, 0, Do)
end

function GM:NetworkEntityCreated(ent)
	if (IsValid(ent) and ent:IsPlayer() and unconnected[ent:UserID()]) then
		unconnected[ent:UserID()] = nil
	end
end

function GM:player_connect_client(info)
	timer.Create("ttt_player_connect_" .. info.userid, 0, 0, function()
		local ply = Player(info.userid)
		if (not IsValid(ply)) then
			return
		end
		hook.Run("PlayerConnected", ply, info)
		timer.Remove("ttt_player_connect_" .. info.userid)
	end)
end

net.Receive("tttrw_console_print", function()
	local text = net.ReadString()

	for i = 1, text:len() + 199, 200 do
		Msg(text:sub(i, i + 199))
	end

	MsgN ""
end)

DEFINE_BASECLASS "gamemode_base"
local color_dead = Color(0xf8, 0xf9, 0x91)
function GM:GetTeamColor(ent)
	if (not ent:Alive()) then
		return color_dead
	end

	return BaseClass.GetTeamColor(self, ent)
end


local tttrw_mcore = CreateConVar("tttrw_mcore", system.IsWindows() and "1" or "0", FCVAR_ARCHIVE, "Enables gmod_mcore_test and such")
local function Callback()
	if (tttrw_mcore:GetBool()) then
		RunConsoleCommand("gmod_mcore_test", "1")
		RunConsoleCommand("mat_queue_mode", "-1")
		RunConsoleCommand("cl_threaded_bone_setup", "1")
	else
		RunConsoleCommand("gmod_mcore_test", "0")
		RunConsoleCommand("mat_queue_mode", "0")
		RunConsoleCommand("cl_threaded_bone_setup", "0")
	end
end
cvars.AddChangeCallback(tttrw_mcore:GetName(), Callback)

hook.Add("HUDPaint", "gmod_mcore_test", function()
	hook.Remove("HUDPaint", "gmod_mcore_test")
	timer.Simple(2, Callback)
end)

function GM:UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local len = velocity:Length()
	local movement = 1.0

	if (len > 0.2) then
		movement = len / maxseqgroundspeed
	end

	local rate = math.min(movement, 2)

	-- if we're under water we want to constantly be swimming..
	if (ply:WaterLevel() >= 2) then
		rate = math.max(rate, 0.5)
	elseif (not ply:IsOnGround() and len >= 1000) then
		rate = 0.1
	end

	ply:SetPlaybackRate(rate)

	if (ply:InVehicle()) then
		--
		-- This is used for the 'rollercoaster' arms
		--
		local Vehicle = ply:GetVehicle()
		local Velocity = Vehicle:GetVelocity()
		local fwd = Vehicle:GetUp()
		local dp = fwd:Dot(Vector( 0, 0, 1))

		ply:SetPoseParameter("vertical_velocity", ( dp < 0 && dp || 0 ) + fwd:Dot( Velocity ) * 0.005)

		-- Pass the vehicles steer param down to the player
		local steer = Vehicle:GetPoseParameter "vehicle_steer"
		steer = steer * 2 - 1 -- convert from 0..1 to -1..1
		if (Vehicle:GetClass() == "prop_vehicle_prisoner_pod" ) then
			steer = 0
			ply:SetPoseParameter("aim_yaw", math.NormalizeAngle(ply:GetAimVector():Angle().y - Vehicle:GetAngles().y - 90))
		end
		ply:SetPoseParameter("vehicle_steer", steer)
	end

	self:GrabEarAnimation(ply)
	self:MouthMoveAnimation(ply)
end