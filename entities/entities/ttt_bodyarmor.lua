AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Body Armour"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"


function ENT:Initialize()
	BaseClass.Initialize(self)
	
	self:RegisterHook("EntityTakeDamage", self.EntityTakeDamage)
end


function ENT:EntityTakeDamage(target, dmg)
	if (dmg:IsBulletDamage()) then
		-- Body armor nets you a damage reduction.
		dmg:ScaleDamage(0.7)
	end
end
