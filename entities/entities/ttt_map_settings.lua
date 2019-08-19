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
	if (key == "cbar_doors") then
		print("[ttt_map_settings] "..key.." set to "..value..".")
	elseif (key == "cbar_buttons") then
		print("[ttt_map_settings] "..key.." set to "..value..".")
	elseif (key == "cbar_other") then
		print("[ttt_map_settings] "..key.." set to "..value..".")
	elseif (key == "plymodel") then
		print("[ttt_map_settings] "..key.." set to "..value..".")
	elseif (key == "propspec_named") then
		print("[ttt_map_settings] "..key.." set to "..value..".")
	elseif (key == "MapSettingsSpawned" or key == "RoundEnd" or key == "RoundPreparation" or key == "RoundStart") then
		self:StoreOutput(key, value)
	end
end

function ENT:Think()
	if self.FirstThink then
		hook.Add("TTTPrepareRound", "MapSettingsPrepareRound", function()
			self:TriggerOutput("RoundPreparation", self)
		end)
		hook.Add("TTTRoundStart", "MapSettingsOutputStart", function()
			self:TriggerOutput("RoundStart", self)
		end)
		hook.Add("TTTRoundEnd", "MapSettingsOutputEnd", function(win)
			self:TriggerOutput("RoundEnd", self, ((win == "traitor" and 2) or (win == "innocent" and 3)))
		end)
		self:TriggerOutput("MapSettingsSpawned", self)
		self.FirstThink = false
	end
end
