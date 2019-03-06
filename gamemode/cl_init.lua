gameevent.Listen "player_disconnect"
gameevent.Listen "player_connect_client"

local unconnected = {}

function GM:player_disconnect(info)
	hook.Run("PlayerDisconnected", Player(info.userid))
end

function GM:NetworkEntityCreated(ent)
	if (IsValid(ent) and ent:IsPlayer() and unconnected[ent:UserID()]) then
		unconnected[ent:UserID()] = nil
	end
end

function GM:player_connect_client(info)
	timer.Create("network_name_" .. info.userid, 0, 0, function()
		local ply = Player(info.userid)
		if (not IsValid(ply)) then
			return
		end
		hook.Run("PlayerConnected", ply, info)
		timer.Remove("network_name_" .. info.userid)
	end)
end


include "sh_init.lua"
include "cl_hud_helpers.lua"
include "cl_hud.lua"
include "cl_scoreboard.lua"