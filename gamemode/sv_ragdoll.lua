local function RagdollRemove(ent)
	ent:Remove()
end
local function RagdollShow(self, ply, ent)
	if (ent ~= self) then
		return
	end

	self:SetOwner(self.Info.Player)
	self:SetNW2String("PlayerName", self.Info.Nick)
	self:SetNW2String("PlayerRole", self.Info.Role)
	self:SetNW2String("PlayerSteamID", self.Info.SteamID)
	hook.Remove("PlayerUse", self)
end

function ttt.CreatePlayerRagdoll(ply)
	if (IsValid(ply.Ragdoll)) then
		return
	end

	local rag = ents.Create("prop_ragdoll")
	rag:SetNW2Bool("IsPlayerRagdoll", true)
	local info
	for _, _info in pairs(round.GetStartingPlayers()) do
		if (_info.Player == ply) then
			info = _info
		end
	end

	rag.Info = info
	ply.Ragdoll = rag
	if not IsValid(rag) then return nil end

	hook.Add("PlayerSpawn", rag, RagdollRemove)
	hook.Add("PlayerUse", rag, RagdollShow)
	rag:SetPos(ply:GetPos())
	rag:SetModel(ply:GetModel())
	rag:SetSkin(ply:GetSkin())

	for key, value in pairs(ply:GetBodyGroups()) do
		rag:SetBodygroup(value.id, ply:GetBodygroup(value.id))
	end

	rag:SetAngles(ply:GetAngles())
	rag:SetColor(ply:GetColor())

	rag:Spawn()
	rag:Activate()


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

	rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end