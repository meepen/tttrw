ENT.Type = "point"
ENT.Base = "base_point"

function ENT:AcceptInput(name, activator, caller)
	if (name == "TraitorWin") then
		local winners = {}

		for _, ply in pairs(round.GetStartingPlayers()) do
			if (ply.Role.Team.Name == "traitor") then
				table.insert(winners, ply)
			end
		end

		round.End("traitor", winners)
	elseif (name == "InnocentWin") then
		local winners = {}

		for _, ply in pairs(round.GetStartingPlayers()) do
			if (ply.Role.Team.Name == "innocent") then
				table.insert(winners, ply)
			end
		end

		round.End("innocent", winners)
	end
end