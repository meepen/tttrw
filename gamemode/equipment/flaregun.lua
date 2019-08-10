EQUIP.Name = "Flare Gun"
EQUIP.Desc = "Burns a body to a crisp."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = true
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    ply:Give("weapon_ttt_flaregun")
end