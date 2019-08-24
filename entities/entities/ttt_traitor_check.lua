ENT.Type = "brush"
ENT.Base = "base_brush"

ENT.Role = "any"

function ENT:KeyValue(key, value)
	if (key == "TraitorsFound") then
		self:StoreOutput(key, value)
	end
end

function ENT:AcceptInput(name, activator)
	if (name == "CheckForTraitor") then
		local min = self:LocalToWorld(self:OBBMins())
		local max = self:LocalToWorld(self:OBBMaxs())
		local ts = 0
		for k,v in pairs(player.GetAll()) do
			if (v:GetRoleTeam() == "traitor") then
				local pos = v:GetPos()
				if ((pos.x > min.x and pos.x < max.x) and (pos.y > min.y and pos.y < max.y) and (pos.z > min.z and pos.z < max.z)) then ts = ts + 1 end
			end
		end
		self:TriggerOutput("TraitorsFound", activator, tostring(ts))
	end
end