EQUIP.Name = "Bodyarmor"
EQUIP.Desc = "Reduces incoming damage."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = false
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    local eq = ents.Create("ttt_bodyarmor")
	eq:SetParent(ply)
    eq:Spawn()
end