DEFINE_BASECLASS "gamemode_base"

function GM:PlayerSetModel(ply)
	ply:SetModel "models/player/phoenix.mdl"

	ply:SetColor(color_white)

	hook.Run("TTTPlayerSetColor", ply)
end

function GM:TTTPlayerGiveWeapons(ply)
	local slots_needed = {
		[1] = true,
		[2] = true
	}

	local slots_left = table.Count(slots_needed)

	for _, wep in RandomPairs(weapons.GetList()) do
		if (wep.AutoSpawnable and slots_needed[wep.Slot]) then
			ply:Give(wep.ClassName)
			slots_needed[wep.Slot] = nil
			slots_left = slots_left - 1
			if slots_left == 0 then
				break
			end
		end
	end
end

function GM:PlayerDeath()
end

function GM:PlayerDeathThink(ply)
	if (IsValid(ply:GetObserverTarget()) and ply:GetObserverMode() == OBS_MODE_IN_EYE) then
		ply:SetPos(ply:GetObserverTarget():GetPos())
	end
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
		warn("Spawn position out of world: %s\n", tostring(pos))
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
GM.TTTCompatibleClasses = GM.TTTCompatibleClasses or setmetatable({}, {
	__index = function(self, k)
		return k
	end
})

function GM:SetupTTTCompatibleEntities()
	-- table.Copy is necessary for non dupe
	for _, ent in pairs(weapons.GetList()) do
		if (ent.TTTCompat) then
			for _, name in pairs(ent.TTTCompat) do
				self.TTTCompatibleClasses[name] = ent.ClassName
				scripted_ents.Register({
					Base = "replacement_entity",
					OverrideClass = ent.ClassName
				}, name)
			end
		end
	end
end

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

			table.insert(self.MapEntities, {
				class = self.TTTCompatibleClasses[class],
				pos = Vector(x, y, z),
				ang = Angle(pitch, yaw, roll),
				kv = kv
			})
		end
	end
end

function GM:SpawnMapEntities()
	for _, ent in pairs(self.MapEntities) do
		local e = ents.Create(ent.class)
		if (not IsValid(e)) then
			warn("Tried to create %s (invalid class)\n", ent.class)
			continue
		end

		e:SetPos(ent.pos)
		e:SetAngles(ent.ang)

		if (ent.kv and ent.kv ~= "") then
			for k, v in ent.kv:gmatch("(%S+)%s*(%S+)%s*") do
				e:SetKeyValue(k, v)
			end
		end

		e:Spawn()
	end
end