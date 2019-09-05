AddCSLuaFile()

ENT.Base = "ttt_equipment_info"
DEFINE_BASECLASS(ENT.Base)
ENT.PrintName = "TTT Body Armour"
ENT.Author = "Ling"
ENT.Contact = "lingbleed@gmail.com"

ENT.Equipment = {
	Name   = "Bodyarmor",
	Desc   = "Reduces incoming damage.",
	CanBuy = { traitor = true, Detective = true },
	Cost   = 1,
	Limit  = 1,
	Icon   = "materials/tttrw/equipment/bodyarmor.png",
}


function ENT:Initialize()
	BaseClass.Initialize(self)
	
	self:RegisterHook("EntityTakeDamage", self.EntityTakeDamage)
end


function ENT:EntityTakeDamage(target, dmg)
	if (target == self:GetParent() and dmg:IsBulletDamage()) then
		-- Body armor nets you a damage reduction.
		dmg:ScaleDamage(0.7)
	end
end
