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

local function GetPlayersWhoHear(ply)
    local plys = player.GetAll()
    for i = #plys, 1, -1 do
        if (hook.Run("PlayerCanHearPlayersVoice", plys[i], ply)) then
            table.remove(plys, i)
        end
    end

    return plys
end

util.AddNetworkString "ttt_voice"

function GM:VoiceKey(ply, key)
    if (key == IN_SPEED) then
        net.Start "ttt_voice"
            net.WriteBool(true)
            net.WriteEntity(ply)
        net.Send(GetPlayersWhoHear(ply))
    end
end

function GM:KeyRelease(ply, key)
    if (key == IN_SPEED) then
        net.Start "ttt_voice"
            net.WriteBool(false)
            net.WriteEntity(ply)
        net.Send(GetPlayersWhoHear(ply))
    end
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
