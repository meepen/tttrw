local ang

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if (not IsValid(self.WeaponEnt)) then
		return
	end

	if (self.WeaponEnt:GetOwner() ~= ttt.GetHUDTarget()) then
		return
	end

	self.Attachment = data:GetAttachment()
	local smokepart = "smoke_trail_wild"

	if (self.WeaponEnt.SmokeParticle) then
		smokepart = self.WeaponEnt.SmokeParticle
	elseif (self.WeaponEnt.SmokeParticles) then
		smokepart = self.WeaponEnt.SmokeParticles[self.WeaponEnt.DefaultHoldType or self.WeaponEnt.HoldType] or smokepart
	end

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	if (IsValid(self.WeaponEnt:GetOwner())) then
		if self.WeaponEnt:GetOwner() == LocalPlayer() then
			ang = self.WeaponEnt:GetOwner():EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		else
			ang = self.WeaponEnt:GetOwner():EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		end
	end

	local e = self.WeaponEnt
	local a = self.Attachment
	local sp = smokepart

	e.SmokePCF = e.SmokePCF or {}
	local _a = a

	if IsValid(e.SmokePCF[_a]) then
		e.SmokePCF[_a]:StopEmission()
	end

	e.SmokePCF[_a] = CreateParticleSystem(e, sp, PATTACH_POINT_FOLLOW, a)

	if IsValid(e.SmokePCF[_a]) then
		e.SmokePCF[_a]:StartEmission()
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
