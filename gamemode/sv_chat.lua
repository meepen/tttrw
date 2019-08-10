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
    print(ply,text,team)
    local replacements = {}

    if (IsValid(ply.Target)) then
        replacements["{target}"] = ply.Target:Nick()
    else
        replacements["{target}"] = "nobody"
    end

    return text:gsub("{.+}", replacements)
end

function GM:PlayerCanSeePlayersChat(text, team, listener, speaker)
    if (listener:Alive() and not speaker:Alive()) then
        return false
    end

    if (team) then
        local lr, sr = ttt.roles[listener:GetRole()], ttt.roles[speaker:GetRole()]

        if (not lr.TeamChatSeenBy or not sr.TeamChatSeenBy) then
            print"false2"
            return false
        end
        
        if (not sr.TeamChatCanBeSeenBy[listener:GetRole()] or not sr.TeamChatCanBeSeenBy[lr.Team.Name]) then
            print"false"
            return false
        end
    end
end

function GM:PlayerCanHearPlayersVoice(hear,talk)
    if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
        return true, false
    else
        if !(IsValid(hear) and IsValid(talk)) then return end
        if (!talk:Alive() and hear:Alive()) then
            return false, false
        elseif !(talk:Alive() or hear:Alive()) then
            return true, false
        end
        if (ttt.GetRoundState() == ttt.ROUNDSTATE_ACTIVE) then
            if (round.Players[talk:UserID()].Role == ttt.roles["Traitor"] and talk.tchat) then
                if (round.Players[hear:UserID()].Role == ttt.roles["Traitor"]) then
                    return true, false
                else
                    return false, false
                end
            end
        end
        return true, false
    end
end

function GM:KeyPress(ply, key)
    if (ply ~= LocalPlayer() or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        if !(IsValid(ply)) then return end
        ply.tchat = true
        print(ply:Nick()..":"..tostring(ply.tchat))
        ply:ConCommand("+voicerecord")
    end
end

function GM:KeyRelease(ply, key)
    if (ply ~= LocalPlayer() or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        if !(IsValid(ply)) then return end
        ply.tchat = false
        print(ply:Nick()..":"..tostring(ply.tchat))
        ply:ConCommand("-voicerecord")
    end
end