function GM:PlayerHit(atk, dmg, dmgtype, hitgroup)
    if (atk ~= LocalPlayer()) then
        return
    end

    surface.PlaySound "tttrw/hitmarker.mp3" 
end