function GM:EntityTakeDamage(vic, dmg)
    local atk = dmg:GetAttacker()

    if (not IsValid(atk) or not atk:IsPlayer() or not vic:IsPlayer()) then
        return
    end

    local hitmarker = ents.Create "ttt_damagenumber"
    hitmarker:SetOwner(atk)
    hitmarker:SetDamage(dmg:GetDamage())
    hitmarker:SetDamageType(dmg:GetDamageType())
    hitmarker:SetPos(dmg:GetDamagePosition())
    hitmarker:Spawn()
end