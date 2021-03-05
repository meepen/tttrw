game.AddParticles "particles/tfa_smoke.pcf"

function SWEP:UpdateMuzzleAttachment()
end

function SWEP:GetMuzzleAttachment()
	local muzzle_id = self:GetOwner():GetViewModel(self:ViewModelIndex()):LookupAttachment "muzzle"
	return muzzle_id == 0 and 1 or muzzle_id
end

function SWEP:MuzzleEffects()
	self:UpdateMuzzleAttachment()
	local att = self:GetMuzzleAttachment()
	local fx = EffectData()
	fx:SetOrigin(self:GetOwner():GetShootPos())
	fx:SetNormal(self:GetOwner():EyeAngles():Forward())
	fx:SetEntity(self:GetOwner():GetViewModel(self:ViewModelIndex()))
	fx:SetScale(100)
	fx:SetAttachment(att)
	util.Effect("tfa_muzzlesmoke", fx)
end