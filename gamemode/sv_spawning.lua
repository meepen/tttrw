DEFINE_BASECLASS "gamemode_base"

function GM:PlayerSetModel(ply)
	ply:SetModel "models/player/phoenix.mdl"

	ply:SetColor(color_white)

	hook.Run("TTTPlayerSetColor", ply)
end

function GM:PlayerLoadout(ply)
	-- can provide weapons here
	BaseClass.PlayerLoadout(self, ply)

	-- check if they need any spawning weapons that weren't provided
	local wpns = ply:GetWeapons()

	local slots = {}

	for _, wep in pairs(wpns) do
		slots[wep.Slot] = true
	end

	if (not slots[1]) then
		ply:Give "weapon_ttt_ak47"
	end
end

function GM:PlayerDeathThink(ply)
	return false
end

local SpawnEntities = {
	"info_player_deathmatch", "info_player_combine", "info_player_rebel",
	"info_player_counterterrorist", "info_player_terrorist", "info_player_axis",
	"info_player_allies", "gmod_player_start", "info_player_teamspawn",
	"ttt_playerspawn"
}

for k,v in pairs(SpawnEntities) do
	scripted_ents.Register({
		Base = "ttt_fake_spawn",
	}, v)
end

function ttt.GetSpawnEnts(force_all)
	local tbl = {}
	for _, classname in pairs(SpawnEntities) do
		for _, e in pairs(ents.FindByClass(classname)) do
			if (IsValid(e) and not e.BeingRemoved) then
				table.insert(tbl, e)
			end
		end
	end

	-- Don't use info_player_start unless absolutely necessary, because eg. TF2
	-- uses it for observer starts that are in places where players cannot really
	-- spawn well. At all.
	if (force_all or #tbl == 0) then
		for _, e in pairs(ents.FindByClass "info_player_start") do
			if (IsValid(e) and not e.BeingRemoved) then
				table.insert(tbl, e)
			end
		end
	end

	return tbl
end

-- Generate points next to and above the spawn that we can test for suitability
local function PointsAroundSpawn(spwn)
	if not IsValid(spwn) then return {} end
	local pos = spwn:GetPos()

	local w, h = 36, 72 -- bit roomier than player hull

	-- all rigged positions
	-- could be done without typing them out, but would take about as much time
	return {
		pos + Vector( w,  0,  0),
		pos + Vector( 0,  w,  0),
		pos + Vector( w,  w,  0),
		pos + Vector(-w,  0,  0),
		pos + Vector( 0, -w,  0),
		pos + Vector(-w, -w,  0),
		pos + Vector(-w,  w,  0),
		pos + Vector( w, -w,  0)
		--pos + Vector( 0,  0,  h) -- just in case we're outside
	};
end

local function IsSpawnpointSuitable(ply, pos, rigged)
	if (not IsValid(ply)) then
		return true
	end

	if (not util.IsInWorld(pos)) then
		warn("Spawn osition out of world: %s\n", tostring(pos))
		return false
	end

	local blocking = ents.FindInBox(pos + Vector(-16, -16, 0), pos + Vector(16, 16, 64))

	for k, p in pairs(blocking) do
		if (IsValid(p) and p:IsPlayer() and p:Alive()) then
			return false
		end
	end

	return true
end

function GM:PlayerSelectSpawnPosition(ply)
	local spawn_locations = ttt.GetSpawnEnts()


	for _, ent in RandomPairs(spawn_locations) do
		if (IsSpawnpointSuitable(ply, ent:GetPos(), true)) then
			return ent:GetPos()
		end
	end

	for _, ent in RandomPairs(spawn_locations) do
		for _, pos in RandomPairs(PointsAroundSpawn(ent:GetPos())) do
			if (IsSpawnpointSuitable(ply, pos, false)) then
				return pos
			end
		end
	end
end

function GM:PlayerSelectSpawn(ply)
	local pos = hook.Run("PlayerSelectSpawnPosition", ply)

	if (not pos) then
		warn("NO SPAWN\n")
		ply:Kill()
		return
	end

	local e = ents.Create "ttt_fake_spawn"
	e:SetPos(pos)
	return e
end

GM.MapEntities = GM.MapEntities or {}

function GM:SetupTextFileEntities()
	local fname = "maps/" .. game.GetMap() .. "_ttt.txt"

	if (not file.Exists(fname, "GAME")) then
		return
	end

	local fcont = file.Read(fname, "GAME")

	local settings = {}

	for _, line in ipairs(string.Explode("\n", fcont)) do
		if (line:match "^#" or line == "" or line:byte(1, 1) == 0) then
			continue
		end

		if (line:match "^setting") then
			warn("Settings not implemented for map files, ignoring: %s\n", line)
		else
			local class, x, y, z, pitch, yaw, roll, kv = line:match("^" .. string.rep("(%S+)%s*", 7) .. "(.*)$")

			table.insert(self.MapEntities, class)

			local e = ents.Create(class)
			if (not IsValid(e)) then
				warn("Tried to create %s (invalid class)\n", class)
				continue
			end

			e:SetPos(Vector(x, y, z))
			e:SetAngles(Angle(pitch, yaw, roll))

			if (kv and kv ~= "") then
				for k, v in kv:gmatch("(%S+)%s*(%S+)%s*") do
					e:SetKeyValue(k, v)
				end
			end

			e:Spawn()
		end
	end
end

function GM:TTTAddPermanentEntities(list)
	for _, class in pairs(self.MapEntities) do
		table.insert(list, class)
	end
end