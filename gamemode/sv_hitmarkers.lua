resource.AddFile "sound/tttrw/hitmarker_.mp3"
resource.AddFile "sound/tttrw/hitmarker_hs_.mp3"

function GM:CreateHitmarkers(vic, dmg)
    local atk = dmg:GetAttacker()

    if (not IsValid(atk) or not vic:IsPlayer()) then
        return
    end

    if (not hook.Run("PlayerShouldTakeDamage", vic, atk)) then
        return
    end

    local hitmarker = ents.Create "ttt_damagenumber"
    hitmarker:SetOwner(atk)
    hitmarker:SetDamage(dmg:GetDamage())
    hitmarker:SetDamageType(dmg:GetDamageType())
    hitmarker:SetPos(dmg:GetDamagePosition())
    hitmarker:SetHitGroup(dmg:GetDamageCustom())
    hitmarker:Spawn()
end