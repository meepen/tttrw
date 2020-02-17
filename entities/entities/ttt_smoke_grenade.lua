AddCSLuaFile()

ENT.PrintName = "Smoke Grenade"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

function ENT:Explode()
	-- Smoke particles can't get cleaned up when a round restarts, so prevent
	-- them from existing post-round.
	if (ttt.GetRoundState() == ttt.ROUNDSTATE_ENDED) then
		return
	end

	local data = EffectData()

	data:SetStart(self:GetPos())
	data:SetMagnitude(8)
	data:SetRadius(80) -- 10 = 1 meter
	util.Effect("tttrw_smoke", data, true, true)
end