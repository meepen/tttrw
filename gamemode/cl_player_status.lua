if not ttt.playerStatus then ttt.playerStatus = {} end

ttt.STATUS_HEADER = -2
ttt.STATUS_DEAD = -1
ttt.STATUS_DEFAULT = 0
ttt.STATUS_MISSING = 1
ttt.STATUS_KOS = 2
ttt.STATUS_AVOID = 3
ttt.STATUS_SUSPECT = 4
ttt.STATUS_FRIEND = 5

ttt.Status = {
	[ttt.STATUS_HEADER] = {
		text = "Status",
		color = Color(0,0,0,0)
	},
	[ttt.STATUS_DEAD] = {
		text = "Dead",
		color = Color(0,0,0,0)
	},
	[ttt.STATUS_DEFAULT] = {
		text = "...",
		color = Color(38, 44, 46)
	},
	[ttt.STATUS_MISSING] = {
		text = "Missing",
		color = Color(103, 90, 110)
	},
	[ttt.STATUS_KOS] = {
		text = "KOS",
		color = Color(175, 47, 36)
	},
	[ttt.STATUS_AVOID] = {
		text = "Avoid",
		color = Color(179, 98, 27)
	},
	[ttt.STATUS_SUSPECT] = {
		text = "Suspect",
		color = Color(175, 149, 49)
	},
	[ttt.STATUS_FRIEND] = {
		text = "Friend",
		color = Color(56, 172, 87)
	}
}

hook.Add("TTTPrepareRound", "ResetPlayerStatus", function()
	ttt.playerStatus = {}
end)

function ttt.SetPlayerStatus(ply, status)
	if (not IsValid(ply)) then return end
	if (status >= ttt.STATUS_DEFAULT and status <= ttt.STATUS_FRIEND) then
		ttt.playerStatus[ply] = status
	else
		ttt.playerStatus[ply] = ttt.STATUS_DEFAULT
	end
end

function ttt.GetPlayerStatus(ply)
	return ttt.playerStatus[ply] or ttt.STATUS_DEFAULT
end