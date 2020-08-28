local function RagdollRemove(ent)
	ent:Remove()
	if (IsValid(ent.HiddenState)) then
		ent.HiddenState:Remove()
	end
end

function GM:TTTCreatePlayerRagdoll(ply)
	local rag = ents.Create "prop_ragdoll"
	rag:SetPos(ply:GetPos())
	rag:SetModel(ply:GetModel())
	rag:SetSkin(ply:GetSkin())
	for key, value in pairs(ply:GetBodyGroups()) do
		rag:SetBodygroup(value.id, ply:GetBodygroup(value.id))
	end

	rag:SetAngles(ply:GetAngles())
	rag:SetColor(ply:GetColor())
	rag:Spawn()
	rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
			local bp, ba = ply:GetBonePosition(rag:TranslatePhysBoneToBone(i))
			if bp and ba then
				bone:SetPos(bp)
				bone:SetAngles(ba)
			end

			bone:SetVelocity(ply:GetVelocity())
		end
	end

	return rag
end

function ttt.CreatePlayerRagdoll(ply, atk, dmg)
	if (IsValid(ply.Ragdoll)) then
		return
	end

	local rag = hook.Run("TTTCreatePlayerRagdoll", ply, atk, dmg)
	rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	if (not IsValid(rag)) then
		pwarnf("NO RAGDOLL FOR PLAYER")
		return
	end

	hook.Add("TTTPrepareRound", rag, RagdollRemove)
	hook.Add("TTTBeginRound", rag, RagdollRemove)
	rag:SetNW2Bool("IsPlayerBody", true)

	rag.Info = info
	rag.Cleanup = true

	local info
	for _, _info in pairs(round.GetStartingPlayers()) do
		if (_info.Player == ply) then
			info = _info
		end
	end

	ply.Ragdoll = rag

	rag.HiddenState = ents.Create "ttt_body_info_container"

	rag.HiddenState.Information = {
		Victim = ply,
		Attacker = atk,
		DamageInfo = dmg
	}

	rag.HiddenState:SetRagdoll(rag)
	rag.HiddenState:SetPlayer(ply)
	rag.HiddenState:Spawn()

	hook.Run("PlayerRagdollCreated", ply, rag, atk, dmg)

	return rag
end

function GM:TTTActivePlayerDisconnected(ply)
	ttt.CreatePlayerRagdoll(ply)
end

function GM:InitializeBodyData(variables, Information)
	table.insert(variables, {
		Title = Information.Victim:GetRole() .. (Information.Victim:GetRoleData().Evil and "!" or ""),
		Icon = Information.Victim:GetRoleData().DeathIcon or "materials/tttrw/xbutton128.png",
		Description = Information.Victim:Name() .. " was " .. Information.Victim:GetRole()
	})

	if (not Information.DamageInfo) then
		return
	end

	local wep = Information.DamageInfo:GetInflictor()
	if (IsValid(wep)) then
		table.insert(variables, {
			Title = "Weapon",
			Icon = "WEAPON_" .. wep:GetClass(),
			Description = "This person appears to have died from a " .. (wep.PrintName or wep:GetClass())
		})
	end

	local hitgroup = Information.Victim:LastHitGroup()

	if (hitgroup == HITGROUP_HEAD) then
		table.insert(variables, {
			Title = "Missing brain",
			Icon = "materials/tttrw/headshot.png",
			Description = "This person appears to have been shot clean through the skull"
		})
	end
end