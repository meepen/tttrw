function GM:KeyPress(ply, key)
    if (not IsFirstTimePredicted()) then return end
    if (ply:GetRole() ~= "Traitor" or not ply:Alive()) then return end
    if (key == IN_SPEED) then
        if not (IsValid(ply)) then return end
        ply.tchat = true
        RunConsoleCommand("+voicerecord")
    end
end

function GM:KeyRelease(ply, key)
    if (not IsFirstTimePredicted()) then return end
    if (ply:GetRole() ~= "Traitor" or not ply:Alive()) then return end
    if (key == IN_SPEED) then
        if not (IsValid(ply)) then return end
        ply.tchat = false
        RunConsoleCommand("-voicerecord")
    end
end