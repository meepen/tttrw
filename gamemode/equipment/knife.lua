EQUIP.Name = "Knife"
EQUIP.Desc = "One use, instakill."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = true
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    ply:Give("weapon_ttt_knife")
end