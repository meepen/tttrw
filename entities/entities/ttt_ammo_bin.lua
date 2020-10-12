AddCSLuaFile()

ENT.PrintName = "Ammo Bin"

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.AmmoMax = 240

ENT.Cooldown = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "AmmoTaken")
end

function ENT:Initialize()
    self:SetModel("models/props_junk/TrashBin01a.mdl")

    if (SERVER) then
        self:PhysicsInit(SOLID_VPHYSICS)
    end
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(200)
    end

    if (CLIENT) then
        hook.Add("PostDrawEffects", self, self.PostDrawEffects)
    end

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
end

function ENT:Draw()
    self:DrawModel()
end

if (CLIENT) then
    surface.CreateFont("ttt_ammobin", {
        font = "Lato",
        size = 50,
        weight = 500,
    })
end

function ENT:PostDrawEffects()
    if (self:IsDormant()) then
        return
    end

    if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) < 15000) then
        cam.Start3D() -- this doesn't actually update dynamically, just stays at 300% rn
            local ang = (self:GetPos() - EyePos()):Angle():Right():Angle()
            ang:RotateAroundAxis(ang:Forward(), 90)
            cam.Start3D2D(self:GetPos()+Vector(0,0,30), ang, .1)
                draw.DrawText((self.AmmoMax - self:GetAmmoTaken()) .. " ammo left", "ttt_ammobin", 0, 0, Color( 0, 150, 175, 255 ), TEXT_ALIGN_CENTER )
            cam.End3D2D()
        cam.End3D()
    end
end

function ENT:Use(ply)
    if (self.Cooldown) then
        return
    end
    if (not IsValid(ply) or not ply:IsPlayer()) then
        return
    end

    local wep = ply:GetActiveWeapon()
    if (not IsValid(wep) or not wep.Primary or not wep.Primary.Ammo) then
        return
    end
    
    local ammoclass = ttt.ammo.findent(wep.Primary.Ammo)
    if (not ammoclass) then
        return
    end

    local ammo = scripted_ents.GetStored(ammoclass).t
    local max = ammo.AmmoMax

    local current = ply:GetAmmoCount(wep.Primary.Ammo)
    if (current >= max) then
        return
    end
    
    local given = math.min(ammo.AmmoAmount, max - current, self.AmmoMax - self:GetAmmoTaken())

    self:SetAmmoTaken(self:GetAmmoTaken() + given)
    ply:SetAmmo(given + ply:GetAmmoCount(wep.Primary.Ammo), wep.Primary.Ammo)

    if (self:GetAmmoTaken() == self.AmmoMax) then
        ply:ChatPrint "GAY"
    end

    self.Cooldown = true
    timer.Simple(0.5, function()
        self.Cooldown = false
    end)
end
