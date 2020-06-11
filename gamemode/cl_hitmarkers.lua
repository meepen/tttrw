local last_hit = -math.huge

local ttt_hitmarker_sound_hs = CreateConVar("tttrw_hitmarker_sound_hs", "sound/tttrw/hitmarker_hs.wav", FCVAR_ARCHIVE, "Hitmarker sound")
local ttt_hitmarker_sound_hs_volume = CreateConVar("tttrw_hitmarker_sound_hs_volume", 2, FCVAR_ARCHIVE, "Hitmarker sound volume", 0, 10)
local ttt_hitmarker_sound = CreateConVar("tttrw_hitmarker_sound", "sound/tttrw/hitmarker_.mp3", FCVAR_ARCHIVE, "Hitmarker sound")
local ttt_hitmarker_sound_volume = CreateConVar("tttrw_hitmarker_sound_volume", 2, FCVAR_ARCHIVE, "Hitmarker sound volume", 0, 10)
local tttrw_hitmarker_no_direct = CreateConVar("tttrw_hitmarker_no_direct", 1, FCVAR_ARCHIVE, "Disable DMG_DIRECT hitmarker sounds", 0, 1)

function GM:PlayerHit(atk, dmg, dmgtype, hitgroup)
    if (atk ~= LocalPlayer()) then
        return
    end

    last_hit = CurTime()

    if (tttrw_hitmarker_no_direct:GetBool() and bit.band(dmgtype, DMG_DIRECT) == DMG_DIRECT) then
        return
    end

    local snd, vol

    if (hitgroup == HITGROUP_HEAD) then
        snd = ttt_hitmarker_sound_hs:GetString()
        vol = ttt_hitmarker_sound_hs_volume:GetFloat()
    else
        snd = ttt_hitmarker_sound:GetString()
        vol = ttt_hitmarker_sound_volume:GetFloat()
    end

    sound.PlayFile(snd, "mono", function(station, eid, err)
        if (IsValid(station)) then
            station:SetVolume(vol)
            station:Play()
        else
            MsgC(Color(255,0,0,255,err))
        end
    end)
end

local color = Color(220, 220, 220, 255)
local black = Color(0,0,0,255)

function GM:TTTDrawHitmarkers()
    local alpha = 1 - (CurTime() - last_hit) / 0.5

    if (alpha <= 0) then
        return
    end

    alpha = alpha * 255
    color.a = alpha
    black.a = alpha

    local w, h = ScrW(), ScrH()
    local x, y = math.floor(w / 2), math.floor(h / 2)
    surface.SetDrawColor(color)

    for i = -1, 1 do
        surface.DrawLine(x - 15 + i, y - 15, x - 5 + i, y - 5)
        surface.DrawLine(x - 15 + i, y + 15, x - 5 + i, y + 5)
        surface.DrawLine(x + 15 + i, y - 15, x + 5 + i, y - 5)
        surface.DrawLine(x + 15 + i, y + 15, x + 5 + i, y + 5)
    end

    surface.SetDrawColor(color_black)

    for i = -2, 2, 4 do
        surface.DrawLine(x - 15 + i, y - 15, x - 5 + i, y - 5)
        surface.DrawLine(x - 15 + i, y + 15, x - 5 + i, y + 5)
        surface.DrawLine(x + 15 + i, y - 15, x + 5 + i, y - 5)
        surface.DrawLine(x + 15 + i, y + 15, x + 5 + i, y + 5)
    end

    surface.DrawLine(x - 18, y - 16, x - 13, y - 16)
    surface.DrawLine(x + 18, y - 16, x + 13, y - 16)
    surface.DrawLine(x - 18, y + 16, x - 13, y + 16)
    surface.DrawLine(x + 18, y + 16, x + 13, y + 16)

    surface.DrawLine(x - 8, y - 6, x - 3, y - 6)
    surface.DrawLine(x + 8, y - 6, x + 3, y - 6)
    surface.DrawLine(x - 8, y + 6, x - 3, y + 6)
    surface.DrawLine(x + 8, y + 6, x + 3, y + 6)
end

surface.CreateFont("ttt_damagenumber", {
	font = "Lato",
	size = 160,
	weight = 500,
})

ttt.damagenumbers = ttt.damagenumbers or {}
local ID = 0

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

net.Receive("tttrw_damage_number", function()
    local self = {
        Owner = net.ReadEntity(),
        Damage = net.ReadUInt(16),
        DamageType = net.ReadUInt(32),
        Pos = net.ReadVector(),
        HitGroup = net.ReadUInt(8),
        LiveTime = 0.5,
        CreationTime = CurTime(),
        ID = ID,
    }
    table.insert(ttt.damagenumbers, self)

    hook.Run("PlayerHit", self.Owner, self.Damage, self.DamageType, self.HitGroup)

    ID = ID + 1
end)

hook.Add("PostDrawEffects", "pluto_damage_numbers", function()
    cam.Start3D()
        for i = #ttt.damagenumbers, 1, -1 do
            local self = ttt.damagenumbers[i]
            if (self.CreationTime + self.LiveTime < CurTime()) then
                table.remove(ttt.damagenumbers, i)
                continue
            end
            local frac = (CurTime() - self.CreationTime) / self.LiveTime
            local totalfrac = frac

            local path = paths[self.ID % #paths + 1]

            local targ = path[#path]
            for i = 1, #path, 4 do
                local curfrac = path[i]
                if (frac <= curfrac) then
                    targ = Bezier(frac / curfrac, path[i + 1], path[i + 2], path[i + 3])
                    break
                end
                frac = frac - curfrac
            end

            local ang = (self.Pos - EyePos()):Angle():Right():Angle()
            ang:RotateAroundAxis(ang:Forward(), 90)
            cam.Start3D2D(self.Pos, ang, 0.04 + self.Damage / 100 * 0.09)
                cam.IgnoreZ(true)
                    local alpha = Lerp(math.max(totalfrac - 0.5, 0) * 2, 255, 0)
                    local col = ColorAlpha(colors[self.HitGroup] or colors.default, alpha)
                    local outline = ColorAlpha(color_black, alpha)
                    draw.SimpleTextOutlined(self.Damage, "ttt_damagenumber", targ.x, targ.y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 3, outline)
                cam.IgnoreZ(false)
            cam.End3D2D()
        end
    cam.End3D()
end)