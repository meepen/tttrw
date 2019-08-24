local MAX_DISTANCE = 90


function GM:TryInspectBody(ply)
	local tr = ply:GetEyeTrace()

	if (not IsValid(tr.Entity) or tr.HitPos:Distance(ply:GetShootPos()) > MAX_DISTANCE) then
		return false
	end

	if (not tr.Entity:GetNW2Bool("IsPlayerBody", false)) then
		return false
	end

	hook.Run("PlayerInspectBody", ply, tr.Entity, tr.HitPos)
	
	return true
end


function GM:PlayerInspectBody(ply, ent, pos)
	if (CLIENT) then
		if (not IsFirstTimePredicted() or IsValid(ttt.InspectMenu)) then
			return
		end

		ttt.InspectBody = ent
		ttt.InspectMenu = vgui.Create "ttt_body_inspect"
		ttt.InspectMenu:SetSize(ScrW() * 0.25, ScrH() * 0.25)
		ttt.InspectMenu:Center()
		ttt.InspectMenu:MakePopup()
		ttt.InspectMenu:SetKeyboardInputEnabled(false)
		ttt.InspectMenu.Position = pos
		ttt.InspectMenu.MaxDistance = MAX_DISTANCE
	else
		if (ply:KeyDown(IN_WALK) or not ply:Alive()) then
			ent.HiddenState:SetVisibleTo(ply)
		elseif (not ent.HiddenState:GetIdentified()) then
			ent.HiddenState:SetIdentified(true)

			for _, oply in pairs(player.GetAll()) do
				oply:Notify(ply:Nick() .. " has confirmed " .. ent.HiddenState:GetOwner():Nick() .. "'s death")
			end
		end
	end
end