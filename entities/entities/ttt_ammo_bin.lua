AddCSLuaFile()

if CLIENT then
	ENT.PrintName = "Ammo Bin"
	ENT.Icon = "vgui/ttt/icon_knife"
end

ENT.Base = "ttt_point_info"
ENT.Type = "anim"

ENT.PercentRemaining = 300
ENT.Cooldown = false

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
    if (self:GetPos():DistToSqr(LocalPlayer():GetPos()) < 10000) then
        cam.Start3D() -- this doesn't actually update dynamically, just stays at 300% rn
            local ang = (self:GetPos() - EyePos()):Angle():Right():Angle()
            ang:RotateAroundAxis(ang:Forward(), 90)
            cam.Start3D2D(self:GetPos()+Vector(0,0,30), ang, .1)
                draw.DrawText( self.PercentRemaining.."% Remaining", "ttt_ammobin", 0, 0, Color( 0, 150, 175, 255 ), TEXT_ALIGN_CENTER )
            cam.End3D2D()
        cam.End3D()
    end
end

function ENT:Use(ply)
    if not (self.Cooldown) then
        if (IsValid(ply) and ply:IsPlayer()) then
            local wep = ply:GetActiveWeapon()
            if (wep.Primary.MaxClip == nil or wep.Primary.MaxClip == 0) then return end
            local r = wep.Primary.MaxClip - ply:GetAmmoCount(wep:GetPrimaryAmmoType())
            if (r > 0) then
                local p = (r / wep.Primary.MaxClip)*100
                local pr
                if (p > self.PercentRemaining) then
                    pr = self.PercentRemaining
                else
                    pr = p
                end
                local d = math.ceil(pr/100 * wep.Primary.MaxClip)
                if (d == 0) then
                    ply:ChatPrint("No Charge Remaining!")
                else
                    self:EmitSound(Sound("items/ammo_pickup.wav"))
                    ply:SetAmmo(d+ply:GetAmmoCount(wep:GetPrimaryAmmoType()),wep:GetPrimaryAmmoType())
                    self.PercentRemaining = self.PercentRemaining - math.ceil(pr)
                    ply:ChatPrint("Remaining: "..self.PercentRemaining.."%")
                end
                self.Cooldown = true
                timer.Simple(1, function()
                    self.Cooldown = false
                end)
            end
        end
    end
end