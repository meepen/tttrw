ENT.Type = "point"
ENT.Base = "base_point"

ENT.FirstThink = true

--Most of the functionality of this isn't here yet, however it needs to exist like this so maps don't break.

function ENT:AcceptInput(name, activator, call, data)
	if (name == "SetPlayerModels") then
		print("[ttt_map_settings] Attempting to set models to: "..tostring(data) or "nil"..".")
	end
end

function ENT:KeyValue(key, value)
	print("[ttt_map_settings] "..key.." set to "..value..".")
	if (key == "MapSettingsSpawned" or key == "RoundEnd" or key == "RoundPreparation" or key == "RoundStart") then
		self:StoreOutput(key, value)
	end
	local cbar_open = key:match"^cbar_(.+)$"

	if (cbar_open) then
		gmod.GetGamemode().crowbar_unlocks = gmod.GetGamemode().crowbar_unlocks or {}
		gmod.GetGamemode().crowbar_unlocks[cbar_open] = tonumber(value) ~= 0
	end
end

function ENT:Initialize()
	hook.Add("TTTPrepareRound", self, function(self)
		self:TriggerOutput("RoundPreparation", self)
	end)
	hook.Add("TTTRoundStart", self, function(self)
		self:TriggerOutput("RoundStart", self)
	end)
	hook.Add("TTTRoundEnd", self, function(self, win)
		self:TriggerOutput("RoundEnd", self, ((win == "traitor" and 2) or (win == "innocent" and 3)))
	end)
	self:TriggerOutput("MapSettingsSpawned", self)
end