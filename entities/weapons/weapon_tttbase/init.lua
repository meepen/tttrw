util.AddNetworkString "tttrw_developer_hitboxes"

AddCSLuaFile "cl_init.lua"
AddCSLuaFile "shared.lua"
include "shared.lua"

function SWEP:Equip()
    -- TODO(meep): figure out why the fuck this is happening???
    self:GetOwner():RemoveAmmo(24, "Pistol")
end

function SWEP:OnDrop()
    self.Primary.DefaultClip = 0
end

-- TODO(meep): hidden weapons so people can't cheat to see weapons