resource.AddFile "sound/tttrw/hitmarker_.mp3"
resource.AddFile "sound/tttrw/hitmarker_hs_.mp3"

function GM:EntityTakeDamage(vic, dmg)
    local atk = dmg:GetAttacker()

    if (not IsValid(atk) or not vic:IsPlayer()) then
        return
    end

    if (not hook.Run("PlayerShouldTakeDamage", vic, atk) and not (not atk:IsPlayer() and atk:GetClass() == "trigger_hurt")) then
        return
    end

    local hitmarker = ents.Create "ttt_damagenumber"
    hitmarker:SetOwner(atk)
    hitmarker:SetDamage(dmg:GetDamage())
    hitmarker:SetDamageType(dmg:GetDamageType())
    hitmarker:SetPos(dmg:GetDamagePosition())
    hitmarker:SetHitGroup(vic:LastHitGroup())
    hitmarker:Spawn()
end