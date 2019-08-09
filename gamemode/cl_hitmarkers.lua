function GM:PlayerHit(atk, dmg, dmgtype, hitgroup)
    if (atk ~= LocalPlayer()) then
        return
    end

    sound.PlayFile(hitgroup == HITGROUP_HEAD and "sound/tttrw/hitmarker_hs_.mp3" or "sound/tttrw/hitmarker_.mp3", "mono", function(station, eid, err)
        if (IsValid(station)) then
            print(hitgroup == HITGROUP_HEAD)
            station:SetVolume(5)
            station:Play()
        else
            MsgC(Color(255,0,0,255,err))
        end
    end)
end