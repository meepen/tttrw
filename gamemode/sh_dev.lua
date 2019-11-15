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

concommand.Add("list_weapon_info", function()
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

		printf("%s (%s):\n\tDMG: %i * %i\n\tRPM: %i\n\tRCL: %.2f\n\tCLP: %i\n\tSPR: %s\n\tRLD: %.2f\n\tDPL: %.2f", 
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

		for dam, t in SortedPairsByMemberValue(damages, "Damage", true) do
			dam = dam * wep.Bullets.Num
			printf("\t%s\n\t\tDMG: %i\n\t\tDPS: %.1f", table.concat(t, ", "), dam, dam / wep.Primary.Delay)
		end
	end
end)