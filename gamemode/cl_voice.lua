function GM:VoiceKey(ply, key)
    if (not IsFirstTimePredicted()) then return end
    local channel = ply:GetRoleData().VoiceChannel
    if (not channel or not ply:Alive()) then return end
    if (key == IN_SPEED) then
        ply.VoiceChannel = true
        RunConsoleCommand("+voicerecord")
    end
end

function GM:KeyRelease(ply, key)
    if (not IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        if (ply.VoiceChannel) then
            RunConsoleCommand("-voicerecord")
        end
        ply.VoiceChannel = nil
    end
end