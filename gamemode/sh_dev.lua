local fulltime = 1

hook.Add("StartCommand", "Bots", function(ply, cmd)
	if (ply:IsBot()) then
		local dur = CurTime() % fulltime
	
		if (dur < fulltime / 2) then
			--cmd:SetSideMove(-10000)
		else
			--cmd:SetSideMove(10000)
		end
		cmd:SetViewAngles(Angle(90, 0, 0))
		--cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
	end
end)

local Hitgroups = {
	[HITGROUP_GENERIC] = "Generic",
	[HITGROUP_HEAD] = "Head",
	[HITGROUP_CHEST] = "Chest",
	[HITGROUP_STOMACH] = "Stomach",
	[HITGROUP_LEFTARM] = "Left Arm",
	[HITGROUP_RIGHTARM] = "Right Arm",
	[HITGROUP_LEFTLEG] = "Left Leg",
	[HITGROUP_RIGHTLEG] = "Right Leg",
	[HITGROUP_GEAR] = "Gear",
}

local function VectorString(x)
	return string.format("Vector(%.2f, %.2f)", x.x, x.y)
end

local function generate_info(printf)
	local dmg = DamageInfo()
	for _, wep in pairs(weapons.GetList()) do
		if (not wep.AutoSpawnable) then
			continue
		end

		DEFINE_BASECLASS(wep.ClassName)

		local damages = {}
		for hitgroup, name in pairs(Hitgroups) do
			dmg:SetDamage(wep.Primary.Damage)
			BaseClass:ScaleDamage(hitgroup, dmg)
			local dam = dmg:GetDamage()
			damages[dam] = damages[dam] or {
				Damage = dam
			}
			table.insert(damages[dam], name)
		end

		printf("%s (%s):\n\tDMG: %.2f * %i\n\tRPM: %i\n\tRCL: %.2f\n\tCLP: %i\n\tSPR: %s\n\tRLD: %.2f\n\tDPL: %.2f", 
			wep.PrintName, wep.ClassName,
			wep.Primary.Damage,
			wep.Bullets.Num,
			60 / wep.Primary.Delay,
			wep.Primary.Recoil,
			wep.Primary.ClipSize,
			VectorString(wep.Bullets.Spread),
			wep.ReloadSpeed or 1,
			wep.DeploySpeed or 1
		)

		if (wep.Bullets) then
			local b = wep.Bullets
			printf("\tBULLETINFO\n\t\tMINRNG: %.2f\n\t\tMAXRNG: %.2f\n\t\tHULLSZE: %.2f\n\t\tMINPCT: %.2f",
				b.DamageDropoffRange,
				b.DamageDropoffRangeMax,
				b.HullSize,
				b.DamageMinimumPercent
			)
		end

		if (wep.Ironsights) then
			local i = wep.Ironsights

			printf("\tIRONSIGHTS\n\t\tTIMETO: %.2f\n\t\tTIMEFM: %.2f\n\t\tSLOWDN: %.2f\n\t\tZOOMIE: %.2f",
				i.TimeTo,
				i.TimeFrom,
				i.SlowDown,
				i.Zoom
			)
		end


		for dam, t in SortedPairsByMemberValue(damages, "Damage", true) do
			dam = dam * wep.Bullets.Num
			printf("\t%s\n\t\tDMG: %i\n\t\tDPS: %.1f", table.concat(t, ", "), dam, dam / wep.Primary.Delay)
		end
	end
end

concommand.Add("list_weapon_info", function()
	generate_info(printf)
end)

concommand.Add("save_weapon_info", function(ply, cmd, args)
	if (IsValid(ply) and SERVER) then
		return
	end

	local f = file.Open(args[1], "wb", "DATA")

	if (not f) then
		printf("Couldn't open file: %s", tostring(args[1]))
		return
	end

	generate_info(function(fmt, ...)
		f:Write(string.format(fmt .. "\n", ...))
	end)

	f:Close()

	printf("Saved to %s", util.RelativePathToFull("data/" .. args[1]))
end)