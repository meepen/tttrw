ENT.Type = "point"
ENT.Base = "base_point"

ENT.Message = ""
ENT.Color = COLOR_WHITE

local RECEIVE_ACTIVATOR = 0
local RECEIVE_ALL = 1
local RECEIVE_DETECTIVE = 2
local RECEIVE_TRAITOR = 3
local RECEIVE_INNOCENT = 4

ENT.Receiver = RECEIVE_ACTIVATOR

function ENT:KeyValue(key, value)
	if key == "message" then
		self.Message = tostring(value) or "ERROR: bad value"
	elseif key == "color" then
		local mr, mg, mb = string.match(value, "(%d*) (%d*) (%d*)")

		local c = Color(0,0,0)
		c.r = tonumber(mr) or 255
		c.g = tonumber(mg) or 255
		c.b = tonumber(mb) or 255

		self.Color = c
	elseif key == "receive" then
		self.Receiver = tonumber(value)
		if not (self.Receiver and self.Receiver >= 0 and self.Receiver <= 4) then
			ErrorNoHalt("ERROR: ttt_game_text has invalid receiver value\n")
			self.Receiver = RECEIVE_ACTIVATOR
		end
	end
end

function ENT:AcceptInput(name, activator)
	if name == "Display" then
		local recv

		local r = self.Receiver
		if r == RECEIVE_ALL then
			recv = nil
		elseif r == RECEIVE_DETECTIVE then
			recv = round.GetActivePlayersByRole "Detective"
		elseif r == RECEIVE_TRAITOR then
			recv = round.GetActivePlayersByRole "traitor"
		elseif r == RECEIVE_INNOCENT then
			recv = round.GetActivePlayersByRole "Innocent"
		elseif r == RECEIVE_ACTIVATOR then
			if not (IsValid(activator) and activator:IsPlayer()) then
				ErrorNoHalt("ttt_game_text tried to show message to invalid !activator\n")
				return true
			end
			recv = {activator}
		end

		print(self.Message)
		PrintTable(recv)
		--Temporary, until the UI elements are added for real, this is needed for compatability
		for k,v in pairs(recv or player.GetAll()) do
			v:ChatPrint(self.Message)
		end

		return true
	end
end