AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Body Armour"
ENT.Author = "Meepen"
ENT.Contact = "meepdarknessmeep@gmail.com"




function ENT:Equipment_EntityTakeDamage(dmg)
	if (dmg:IsBulletDamage()) then
		-- Body armor nets you a damage reduction.
		dmg:ScaleDamage(0.7)
	end
end
