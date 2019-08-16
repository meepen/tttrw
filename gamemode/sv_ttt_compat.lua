function GM:SetupTTTCompatibleEntities()
    for _, ent in pairs(weapons.GetList()) do
        if (ent.ClassName:find "_ttt_") then
            scripted_ents.Register({
                Base = "ttt_zm_replacement"
            }, ent.ClassName:gsub("_ttt_", "_zm_"))
        end
        if (ent.TTTCompat) then
            for _, name in pairs(ent.TTTCompat) do
                scripted_ents.Register({
                    Base = "ttt_zm_replacement",
                    OverrideClass = ent.ClassName
                }, name)
            end
        end
    end
end

function ENTITY:SetDamageOwner(ply)
    self.dmg_owner = {ply = ply, t = CurTime()}
end

function ENTITY:GetDamageOwner()
    if (not self.dmg_owner) then
        return
    end

    return self.dmg_owner.ply, self.dmg_owner.t
end