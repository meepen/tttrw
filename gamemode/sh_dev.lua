local fulltime = 1

hook.Add("StartCommand", "Bots", function(ply, cmd)
	if (ply:IsBot()) then
		local dur = CurTime() % fulltime
	
		if (dur < fulltime / 2) then
			cmd:SetSideMove(-10000)
		else
			cmd:SetSideMove(10000)
		end
		cmd:SetViewAngles(Angle(90, 0, 0))
		--cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
	end

end)