AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Disguiser"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

ENT.Equipment = {
	Name   = "Disguiser",
	Desc   = "Hide your name from other players, so you can act without being known.",
	CanBuy = { traitor = true },
	Cost   = 1,
	Limit  = 1,
	Icon   = "materials/tttrw/equipment/disguiser.png",
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
	concommand.Add("ttt_toggle_disguise", function(pl)
		for k, v in pairs(pl:GetChildren()) do
			if (v:GetClass() == "ttt_disguiser") then
				v:Toggle()
				pl:ChatPrint(v:GetNW2Bool("Enabled") and "Disguise enabled!" or "Disguise disabled.")
			end
		end
	end)
else
	function ENT:Initialize()
		BaseClass.Initialize(self)
		chat.AddText "Use this console command to toggle your diguiser: ttt_toggle_disguise"
	end
end

function PLAYER:HasDisguiser()
	for k, v in pairs(self:GetChildren()) do
		if (v:GetClass() == "ttt_disguiser") then
			return v:GetNW2Bool("Enabled")
		end
	end
end
