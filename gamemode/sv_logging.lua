function GM:InsertLog(...)
    table.insert(self.CurrentLogs, {
        Time = CurTime(),
        Text = string.format(...)
    })

    print(string.format("%.2f: %s", CurTime() - self.StartTime, string.format(...)))
end

function GM:DamageLogs_FormatPlayer(ply)
    return string.format("%s <%s>", ply:Nick(), ply:GetRole())
end

function GM:DamageLogs_EntityTakeDamage(vic, dmg)
    if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
        return
    end

    if (not vic:IsPlayer()) then
        return
    end

    local text = self:DamageLogs_FormatPlayer(vic) .. " took " .. dmg:GetDamage() .. " damage"
    local wep, atk = dmg:GetInflictor(), dmg:GetAttacker()
    if (IsValid(wep) and wep:IsWeapon()) then
        text = text .. " from a " .. (wep.PrintName or wep:GetClass())
    end

    if (IsValid(atk)) then
        if (atk:IsPlayer()) then
            text = self:DamageLogs_FormatPlayer(atk) .. " damaged " .. self:DamageLogs_FormatPlayer(vic) .. " for " .. dmg:GetDamage() .. " damage"
        else
            text = text .. " by " .. atk:GetClass()
        end
    end

    self:InsertLog(text)
end

function GM:DamageLogs_TTTPrepareRound()
    self.StartTime = CurTime()
    self.CurrentLogs = {}
end

function GM:DamageLogs_TTTEndRound()
    local text = {}


    for i, log in ipairs(self.CurrentLogs) do
        text[i] = string.format("%.2f: %s", log.Time - self.StartTime, log.Text)
    end

    text = table.concat(text, "\n")

    for _, ply in pairs(player.GetAll()) do
        ply:ConsolePrint(text)
    end
end

function GM:TTTTraitorButtonActivated(ent, ply)
    self:InsertLog("%s has actived %s", self:DamageLogs_FormatPlayer(ply), ent:GetClass())
end