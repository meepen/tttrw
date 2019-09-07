util.AddNetworkString "ttt_player_target"

net.Receive("ttt_player_target", function(len, cl)
    local ent = net.ReadEntity()

    if (IsValid(ent) and (ent:IsPlayer() or ent:GetNW2Bool("IsPlayerBody", false))) then
        cl:SetTarget(ent)
    end
    timer.Create("EliminateTargetFor" .. cl:UserID(), 3, 1, function()
        if (IsValid(cl)) then
            cl:SetTarget(nil)
        end
    end)
end)

function GM:PlayerSay(ply, text, team)
    return hook.Run("FormatPlayerText", ply, text)
end

function GM:PlayerCanSeePlayersChat(text, team, listener, speaker)
    if (listener:Alive() and not speaker:Alive() and ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
        return false
    end

    if (team) then
        local lr = speaker:GetRoleData()

        if (not lr.TeamChatCanBeSeenBy) then
            return false
        end
        
        if (not lr.TeamChatCanBeSeenBy[listener:GetRole()] and not lr.TeamChatCanBeSeenBy[listener:GetRoleTeam()]) then
            return false
        end
    end

    return true
end

function GM:PlayerCanHearPlayersVoice(hear, talk)
    if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
        return true, false
    end

    if (not talk:Alive() and not hear:Alive()) then
        return true, false
    end

    if (not talk:Alive() and hear:Alive()) then
        return false, false
    end

    local channel = talk:GetRoleData().VoiceChannel
    if (channel and talk:KeyDown(IN_SPEED) and hear:GetRoleData().VoiceChannel ~= channel) then
        return false, false
    end

    return true, false
end