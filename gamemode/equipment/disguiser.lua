EQUIP.Name = "Disguiser"
EQUIP.Desc = "Disguises your name from other players."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = true
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    local eq = ents.Create("ttt_disguiser")
	eq:SetParent(ply)
    eq:Spawn()
end