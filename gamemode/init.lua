resource.AddSingleFile "resource/fonts/Lato-Regular.ttf"
resource.AddSingleFile "resource/fonts/Lato-Semibold.ttf"

include "sh_files.lua"

util.AddNetworkString "tttrw_console_print"

function PLAYER:ConsolePrint(text)
    net.Start "tttrw_console_print"
        net.WriteString(text)
    net.Send(self)
end

function GM:PlayerUse(ply)
    return ply:Alive()
end

function GM:EntityTakeDamage(targ, dmg)
    self:CreateHitmarkers(targ, dmg)
    self:DamageLogs_EntityTakeDamage(targ, dmg)
end

function GM:TTTPrepareRound()
    self:SpawnMapEntities()
    self:DamageLogs_TTTPrepareRound()
end

function GM:TTTEndRound()
    self:DamageLogs_TTTEndRound()
end