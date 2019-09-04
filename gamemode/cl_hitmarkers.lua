local last_hit = -math.huge

local ttt_hitmarker_sound_hs = CreateConVar("tttrw_hitmarker_sound_hs", "sound/tttrw/hitmarker_hs_.mp3", FCVAR_ARCHIVE, "Hitmarker sound")
local ttt_hitmarker_sound = CreateConVar("tttrw_hitmarker_sound", "sound/tttrw/hitmarker_.mp3", FCVAR_ARCHIVE, "Hitmarker sound")

function GM:PlayerHit(atk, dmg, dmgtype, hitgroup)
    if (atk ~= LocalPlayer()) then
        return
    end

    last_hit = CurTime()

    sound.PlayFile(hitgroup == HITGROUP_HEAD and ttt_hitmarker_sound_hs:GetString() or ttt_hitmarker_sound:GetString(), "mono", function(station, eid, err)
        if (IsValid(station)) then
            station:SetVolume(2)
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