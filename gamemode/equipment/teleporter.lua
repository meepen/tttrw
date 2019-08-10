EQUIP.Name = "Teleporter"
EQUIP.Desc = "Mark a location with right click, then teleport to it later with left click."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = false
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    ply:Give("weapon_ttt_teleporter")
end