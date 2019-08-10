function GM:KeyPress(ply, key)
    if (LocalPlayer() ~= ply or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        if !(IsValid(ply)) then return end
        ply.tchat = true
        RunConsoleCommand("+voicerecord")
    end
end

function GM:KeyRelease(ply, key)
    if (LocalPlayer() ~= ply or !IsFirstTimePredicted()) then return end
    if (key == IN_SPEED) then
        if !(IsValid(ply)) then return end
        ply.tchat = false
        RunConsoleCommand("-voicerecord")
    end
end