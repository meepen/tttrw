local ttt_round_limit = CreateConVar("ttt_round_limit", 6, FCVAR_NONE, "How many rounds until map change. Lua can override this.")

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
    if (CurTime() > 60 * 60) then
        return true, "Time limit reached"
    end

    if (self.InitialCommit ~= self.CurrentCommit) then
        return not not self.CurrentCommit, "Server lua has been updated."
    end

    if (ttt_round_limit:GetInt() <= ttt.GetRoundNumber()) then
        return true, "Round limit reached."
    end
    
    if (self.InitialCommit ~= self.CurrentCommit and self.CurrentCommit) then
        return true, "Server lua has been updated."
    end

    return hook.Run "TTTShouldChangeMap"
end

function GM:ChangeMap(reason)
    for _, ply in pairs(player.GetAll()) do
        ply:ChatPrint("Server will be changing map. Reason: " .. reason)
    end

    hook.Add("TTTPrepareRound", "ChangeMap", function()
        game.LoadNextMap()
    end)
end