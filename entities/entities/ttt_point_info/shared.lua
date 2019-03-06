AddCSLuaFile()

ENT.Type = "point"
ENT.PrintName = "TTT Point Info"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"

function ENT:Initialize()
	if (SERVER) then
		self:SV_Initialize()
	end
end