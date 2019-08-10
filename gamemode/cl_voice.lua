function GM:KeyPress(ply, key)
    if (ply ~= LocalPlayer() or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        ply.tchat = true
        net.Start("ttt_traitor_voice")
            net.WriteUInt(ply:UserID(), 8)
            net.WriteBool(true)
        net.SendToServer()
        RunConsoleCommand("+voicerecord")
    end
end

function GM:KeyRelease(ply, key)
    if (ply ~= LocalPlayer() or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        ply.tchat = false
        net.Start("ttt_traitor_voice")
            net.WriteUInt(ply:UserID(), 8)
            net.WriteBool(false)
        net.SendToServer()
        RunConsoleCommand("-voicerecord")
    end
end