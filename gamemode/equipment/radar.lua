EQUIP.Name = "Radar"
EQUIP.Desc = "Pings the location of other Terrorists around you, showing you their location."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = false
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    local eq = ents.Create("ttt_radar")
	eq:SetParent(ply)
    eq:Spawn()
end