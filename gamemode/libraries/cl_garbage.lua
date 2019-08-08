garbage = garbage or {}
garbage.Entities = garbage.Entities or {}
garbage.Players = garbage.Players or {}

hook.Add("NetworkEntityCreated", "Garbage Library", function(e)
    local t1 = garbage.Entities[e:EntIndex()]

    if (t1) then
        for _, cb in ipairs(t1) do
            cb(e)
        end
    end

    if (e:IsPlayer()) then
        local t2 = garbage.Players[e:UserID()]
        if (t2) then
            for _, cb in ipairs(t2) do
                cb(e)
            end
        end
    end
end)

function garbage.Entity(entidx, cb)
    if (Entity(entidx)) then
        return cb(Entity(entidx))
    end

    garbage.Entities[entidx] = garbage.Entities[entidx] or {}
    table.insert(garbage.Entities[entidx], cb)
end

function garbage.Player(userid, cb)
    if (Player(entidx)) then
        return cb(Player(userid))
    end

    garbage.Players[entidx] = garbage.Players[entidx] or {}
    table.insert(garbage.Players[entidx], cb)
end