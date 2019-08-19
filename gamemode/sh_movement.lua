local ttt_bhop_sv, ttt_bhop_cl = CreateConVar("ttt_bhop_sv", "1", FCVAR_REPLICATED, "Allows clients to enable auto bhop")
if (CLIENT) then
	ttt_bhop_cl = CreateConVar("ttt_bhop_cl", "1", FCVAR_USERINFO + FCVAR_ARCHIVE, "Enable auto bhop if ttt_bhop_sv is enabled")
end

function GM:Move(ply, mv)
	local data = player_manager.RunClass(ply, "GetSpeedData")

	mv:SetMaxSpeed(mv:GetMaxSpeed() * data.Multiplier * data.FinalMultiplier)
	mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * data.Multiplier * data.FinalMultiplier)

	-- bhop settings

	if (not ply:Alive()) then
		return
	end

	local cl_enabled = ttt_bhop_cl and ttt_bhop_cl:GetBool()
	if (SERVER) then
		cl_enabled = ply:GetInfoNum("ttt_bhop_cl", 0)
	end

	if (cl_enabled and ttt_bhop_sv:GetBool() and bit.band(mv:GetButtons(), IN_JUMP) == IN_JUMP) then
		if (not ply:IsOnGround() or bit.band(mv:GetOldButtons(), IN_JUMP) == IN_JUMP) then
			mv:SetButtons(bit.band(bit.bnot(IN_JUMP), mv:GetButtons()))
		else
			mv:SetButtons(bit.bor(mv:GetButtons(), IN_JUMP))
		end
	end
end

if (SERVER) then
	function GM:GetFallDamage(ply, speed)
		return math.max(0, math.ceil(0.325 * speed - 141.75))
	end
end