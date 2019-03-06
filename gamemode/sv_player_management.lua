function ttt.GetEligiblePlayers()
	local plys = player.GetAll()

	hook.Run("TTTRemoveIneligiblePlayers", plys)

	return plys
end

local ttt_bots_are_spectators = CreateConVar("ttt_bots_are_spectators", "0", FCVAR_NONE, "Bots spawn as players or not.")

function GM:TTTRemoveIneligiblePlayers(plys)
	for i = #plys, 1, -1 do
		local ply = plys[i]
		if (ply:IsBot() and ttt_bots_are_spectators:GetBool()) then
			table.remove(plys, i)
		end
	end
end