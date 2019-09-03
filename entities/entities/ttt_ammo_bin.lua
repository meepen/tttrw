AddCSLuaFile()

ENT.PrintName = "Ammo Bin"
ENT.Icon = "vgui/ttt/icon_knife"

ENT.Base = "ttt_point_info"
ENT.Type = "anim"

ENT.Cooldown = false

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "PercentRemaining")
end

function ENT:Initialize()
    self:SetModel("models/props_junk/TrashBin01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(200)
    end

    if (CLIENT) then
        hook.Add("PostDrawEffects", self, self.PostDrawEffects)
    end

    self:SetPercentRemaining(300)

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
    if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) < 15000) then
        cam.Start3D() -- this doesn't actually update dynamically, just stays at 300% rn
            local ang = (self:GetPos() - EyePos()):Angle():Right():Angle()
            ang:RotateAroundAxis(ang:Forward(), 90)
            cam.Start3D2D(self:GetPos()+Vector(0,0,30), ang, .1)
                draw.DrawText( self:GetPercentRemaining().."% Remaining", "ttt_ammobin", 0, 0, Color( 0, 150, 175, 255 ), TEXT_ALIGN_CENTER )
            cam.End3D2D()
        cam.End3D()
    end
end

function ENT:Use(ply)
    if not (self.Cooldown) then
        if (IsValid(ply) and ply:IsPlayer()) then
            local wep = ply:GetActiveWeapon()
            local pri = wep:GetPrimaryAmmoType()
            local max = ttt.Ammos[game.GetAmmoName(pri)].Max

            local r = max - ply:GetAmmoCount(pri)
            if (r > 0) then
                local p = (r / max) * 100
                local pr
                if (p > self:GetPercentRemaining()) then
                    pr = self:GetPercentRemaining()
                else
                    pr = p
                end
                local d = math.ceil(pr / 100 * max)
                if (d == 0) then
                    ply:ChatPrint("No Charge Remaining!")
                else
                    self:EmitSound(Sound("items/ammo_pickup.wav"))
                    ply:SetAmmo(d + ply:GetAmmoCount(wep:GetPrimaryAmmoType()), wep:GetPrimaryAmmoType())
                    self:SetPercentRemaining(self:GetPercentRemaining() - math.ceil(pr))
                    ply:ChatPrint("Remaining: " .. self:GetPercentRemaining() .. "%")
                end
                self.Cooldown = true
                timer.Simple(1, function()
                    self.Cooldown = false
                end)
            end
        end
    end
end