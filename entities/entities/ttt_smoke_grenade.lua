AddCSLuaFile()

ENT.PrintName = "Smoke Grenade"
ENT.Base = "ttt_basegrenade"
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

DEFINE_BASECLASS "ttt_basegrenade"

function ENT:Explode()
	local spos = self:GetPos()
	local trs = util.TraceLine {
		start  = self:GetPos() + Vector(0, 0, 64),
		endpos = self:GetPos() + Vector(0, 0, -128),
		filter = self
	}

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