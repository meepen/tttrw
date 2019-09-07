local ttt_round_limit = CreateConVar("ttt_round_limit", 6, FCVAR_NONE, "How many rounds until map change. Lua can override this.")


hook.Add("TTTPrepareNetworkingVariables", "RoundNumber", function(vars)
	table.insert(vars, {
		Name = "RoundNumber",
		Type = "Int",
		Default = 0
    })
end)


local function ReadCommitFile()
    local filename = "gamemodes/" .. gmod.GetGamemode().FolderName .. "/commit.json"
    if (not file.Exists(filename, "GAME")) then
        return false
    end

    return util.JSONToTable(file.Read(filename, "GAME"))
end

function GM:TrackCurrentCommit()
    local Commit = ReadCommitFile()

    if (Commit) then
        self.CurrentCommit = Commit.branch.. "#" .. Commit.commit
    else
		self.CurrentCommit = nil
    end

	if (not self.InitialCommit) then
		self.InitialCommit = self.CurrentCommit
	end
end

function GM:CheckPassword(sid64, ipaddr, svpassword, clpassword, name)
	printf("%s [%s] (%s) tried joining with password = %s", name, sid64, ipaddr, clpassword)

	self:TrackCurrentCommit()
	if (self.InitialCommit and not self.CurrentCommit) then -- updating
		return false, "Server is updating, please try reconnecting in a few seconds."
	end
end

function GM:MapVote_TTTBeginRound()
    ttt.SetRoundNumber(ttt.GetRoundNumber() + 1)
end

function GM:MapVote_TTTEndRound()
    self:TrackCurrentCommit()
    
    local should_change, reason = hook.Run "ShouldChangeMap"
    if (should_change) then
        hook.Run("ChangeMap", reason)
    end
end

function GM:ShouldChangeMap()
    if (self.InitialCommit ~= self.CurrentCommit) then
        return not not self.CurrentCommit, "Server lua has been updated."
    end

    if (ttt_round_limit:GetInt() <= ttt.GetRoundNumber()) then
        return true, "Round limit reached."
    end
    
    if (self.InitialCommit ~= self.CurrentCommit and self.CurrentCommit) then
        return true, "Server lua has been updated."
    end

    return false
end

function GM:ChangeMap(reason)
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("Server will be changing map. Reason: " .. reason)
    end

    hook.Add("TTTPrepareRound", "ChangeMap", function()
        game.LoadNextMap()
    end)
end