ENT.Type = "point"
ENT.Base = "base_point"

ENT.Role = "any"

local roleConversion = { [0] = "innocent", "traitor", "Detective", }

function ENT:KeyValue(key, value)
	if key == "OnPass" or key == "OnFail" then
		-- this is our output, so handle it as such
		self:StoreOutput(key, value)
	elseif key == "Role" then
		self.Role = roleConversion[tonumber(value)]
		if not self.Role then
			ErrorNoHalt("ttt_logic_role: bad value for Role key, not a number\n")
			self.Role = "any"
		end
	end
end


function ENT:AcceptInput(name, activator)
	if name == "TestActivator" then
		if IsValid(activator) and activator:IsPlayer() then
			if (self.Role == "any" or self.Role == activator:GetRole() or self.Role == activator:Team()) then
				self:TriggerOutput("OnPass", activator)
			else
				self:TriggerOutput("OnFail", activator)
			end
		end

		return true
	end
end
