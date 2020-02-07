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
    self:NetworkVar("Float", 0, "RealDamage")
    self:NetworkVar("Int", 0, "DamageType")
    self:NetworkVar("Int", 1, "ID")
    self:NetworkVar("Int", 2, "HitGroup")
end

function ENT:GetDamage()
    return math.Round(self:GetRealDamage(), 1)
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

local good_observers = {
    [OBS_MODE_IN_EYE] = true,
    [OBS_MODE_CHASE] = true
}

function ENT:IsVisibleTo(ply)
    return ply == self:GetOwner() or good_observers[ply:GetObserverMode()] and ply:GetObserverTarget() == self:GetOwner()
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
	font = "Lato",
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

local colors = {
    [HITGROUP_HEAD] = Color(255, 0, 0),
    [HITGROUP_CHEST] = Color(128, 20, 108),
    [HITGROUP_STOMACH] = Color(200, 20, 108),
    default = color_white,
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
        cam.Start3D2D(self:GetPos(), ang, 0.04 + self:GetDamage() / 100 * 0.09)
            cam.IgnoreZ(true)
                local alpha = Lerp(math.max(totalfrac - 0.5, 0) * 2, 255, 0)
                local col = ColorAlpha(colors[self:GetHitGroup()] or colors.default, alpha)
                local outline = ColorAlpha(color_black, alpha)
                draw.SimpleTextOutlined(self:GetDamage(), "ttt_damagenumber", targ.x, targ.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, outline)
            cam.IgnoreZ(false)
        cam.End3D2D()
    cam.End3D()
end