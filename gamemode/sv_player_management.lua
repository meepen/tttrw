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
		elseif (ply:GetInfoNum("tttrw_afk", 0) == 1) then
			table.remove(plys, i)
		end
	end
end

timer.Create("tttrw_afk", 0, 0, function()
	for _, info in pairs(round.GetActivePlayers()) do
		if (IsValid(info.Player) and info.Player:GetInfoNum("tttrw_afk", 0) == 1) then
			info.Player:Say "I have been slain for being afk."
			info.Player:Kill()
		end
	end
end)