function ENTITY:SetDamageOwner(ply)
    self.dmg_owner = {ply = ply, t = CurTime()}
end

function ENTITY:GetDamageOwner()
    if (not self.dmg_owner) then
        return
    end

    return self.dmg_owner.ply, self.dmg_owner.t
end