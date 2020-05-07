-- resource.AddFile "sound/tttrw/hitmarker_.mp3"
-- resource.AddFile "sound/tttrw/hitmarker_hs.wav"

local function GetFilter(ply)
    local ret = {ply}
    for _, spec in pairs(player.GetHumans()) do
        if (spec:GetObserverMode() == OBS_MODE_IN_EYE and spec:GetObserverTarget() == ply) then
            ret[#ret + 1] = spec
        end
    end

    return ret
end

util.AddNetworkString "tttrw_damage_number"

function GM:CreateHitmarkers(vic, dmg)
    local atk = dmg:GetAttacker()

    if (not IsValid(atk) or not vic:IsPlayer() or dmg:GetDamage() <= 0) then
        return
    end

    if (not hook.Run("PlayerShouldTakeDamage", vic, atk)) then
        return
    end

    net.Start "tttrw_damage_number"
        net.WriteEntity(atk)
        net.WriteUInt(dmg:GetDamage(), 16)
        net.WriteUInt(dmg:GetDamageType(), 32)
        net.WriteVector(dmg:GetDamagePosition())
        net.WriteUInt(dmg:GetDamageCustom(), 8)
    net.Send(GetFilter(atk))
end