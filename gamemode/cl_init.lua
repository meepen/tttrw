include "sh_files.lua"

gameevent.Listen "player_disconnect"
gameevent.Listen "player_connect_client"
gameevent.Listen "player_spawn"

local unconnected = {}

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