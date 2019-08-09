AddCSLuaFile()

ENT.Base = "ttt_point_info"
ENT.Type = "anim"
ENT.PrintName = "TTT Hitmarker Info"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

ENT.LiveTime = 0.5

DEFINE_BASECLASS "ttt_point_info"

local ID = 0

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Damage")
    self:NetworkVar("Int", 1, "DamageType")
    self:NetworkVar("Int", 2, "ID")
    self:NetworkVar("Int", 3, "HitGroup")
end

function ENT:Initialize()
    if (SERVER) then
        ID = ID + 1
        self:SetID(ID)
    end

	self:DrawShadow(false)
    BaseClass.Initialize(self)
    if (CLIENT) then
        hook.Add("PostDrawEffects", self, self.PostDrawEffects)
    else
        self:NextThink(CurTime() + self.LiveTime)
    end
    hook.Run("PlayerHit", self:GetOwner(), self:GetDamage(), self:GetDamageType(), self:GetHitGroup())
end

function ENT:IsVisibleTo(ply)
    return ply == self:GetOwner()
end

if (SERVER) then
    function ENT:Think()
        self:Remove()
    end
end

if (not CLIENT) then
    return
end

surface.CreateFont("ttt_damagenumber", {
	font = "Arial",
	size = 160,
	weight = 500,
})

local function Bezier(t, startpos, bias, endpos)
    local rt = 1 - t
    return rt * rt * startpos + 2 * rt * t * bias + t * t * endpos
end

local paths = {
    {
        0.4,
        vector_origin,
        Vector(100, -100),
        Vector(200, 0),
        0.6,
        Vector(200, 0),
        Vector(250, 150),
        Vector(250, 300)
    },
    {
        0.4,
        vector_origin,
        Vector(-100, -100),
        Vector(-200, 0),
        0.6,
        Vector(-200, 0),
        Vector(-250, 150),
        Vector(-250, 300)
    }
}

function ENT:PostDrawEffects()
    local frac = (CurTime() - self:GetCreationTime()) / self.LiveTime
    local totalfrac = frac

    local path = paths[self:GetID() % #paths + 1]

    local targ = path[#path]
    for i = 1, #path, 4 do
        local curfrac = path[i]
        if (frac <= curfrac) then
            targ = Bezier(frac / curfrac, path[i + 1], path[i + 2], path[i + 3])
            break
        end
        frac = frac - curfrac
    end

    cam.Start3D()
        local ang = (self:GetPos() - EyePos()):Angle():Right():Angle()
        ang:RotateAroundAxis(ang:Forward(), 90)
        cam.Start3D2D(self:GetPos(), ang, 0.07 + 0.05 * (self:GetDamage() / 100 * 0.05))
            cam.IgnoreZ(true)
                draw.SimpleText(self:GetDamage(), "ttt_damagenumber", targ.x, targ.y, Color(255, 0, 0, Lerp(math.max(totalfrac - 0.5, 0) * 2, 255, 0)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.IgnoreZ(false)
        cam.End3D2D()
    cam.End3D()
end