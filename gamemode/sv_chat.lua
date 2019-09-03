util.AddNetworkString "ttt_player_target"

net.Receive("ttt_player_target", function(len, cl)
    cl.Target = net.ReadEntity()
    if (not IsValid(cl.Target) or not cl.Target:IsPlayer()) then
        cl.Target = nil
    end
    timer.Create("EliminateTargetFor" .. cl:UserID(), 3, 1, function()
        if (IsValid(cl)) then
            cl.Target = nil
        end
    end)
end)

function GM:PlayerSay(ply, text, team)
    local replacements = {}

    if (IsValid(ply.Target)) then
        replacements["{target}"] = ply.Target:Nick()
    else
        replacements["{target}"] = "nobody"
    end

    return text:gsub("{.+}", replacements)
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

function GM:PlayerCanHearPlayersVoice(hear,talk)
    if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
        return true, false
    else
        if (not talk:Alive() and hear:Alive()) then
            return false, false
        elseif not (talk:Alive() or hear:Alive()) then
            return true, false
        end
        local channel = talk:GetRoleData().VoiceChannel
        if (ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE and channel) then
            if (channel and hear:GetRoleData().VoiceChannel == channel) then
                return true, false
            else
                return false, false
            end
        end
        return true, false
    end
end

function GM:VoiceKey(ply, key)
    local channel = ply:GetRoleData().VoiceChannel
    if (not channel or not ply:Alive()) then return end
    if (key == IN_SPEED) then
        ply.VoiceChannel = channel
    end
end

function GM:KeyRelease(ply, key)
    if (key == IN_SPEED) then
        ply.VoiceChannel = nil
    end
end