AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Disguiser"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

ENT.Equipment = {
	Name		   = "Disguiser",
	Desc 		   = "Hide your name from other players, so you can act without being known.",
	Roles	       = { Traitor = true },
	Cost 	   	   = 1,
	Limit	       = 1,
}

function ENT:IsVisibleTo(ply)
	local own = self:GetParent()
	if (own == ply) then
		return true
	end

	return self:GetNW2Bool("Enabled")
end

if (SERVER) then
	function ENT:Toggle()
		self:SetNW2Bool("Enabled", not self:GetNW2Bool("Enabled"))
	end
	
	-- Temporary until we get a UI
	concommand.Add("ttt_disguiser_toggle", function(pl)
		for k, v in pairs(pl:GetChildren()) do
			print(k,v)
			if (v:GetClass() == "ttt_disguiser") then
				v:Toggle()
			end
		end
	end)
end

function PLAYER:HasDisguiser()
	for k, v in pairs(self:GetChildren()) do
		if (v:GetClass() == "ttt_disguiser") then
			return v:GetNW2Bool("Enabled")
		end
	end
end
