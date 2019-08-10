EQUIP.Name = "Ammo Bin"
EQUIP.Desc = "Fills up to 300% of your reserve Ammo."
EQUIP.Cost = 1
EQUIP.Limit = 1

EQUIP.TraitorOnly = false
EQUIP.DetectiveOnly = false

function EQUIP:OnBuy(ply)
    ply:Give("weapon_ttt_ammo_bin")
end