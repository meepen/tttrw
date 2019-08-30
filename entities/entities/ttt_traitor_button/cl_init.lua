include "shared.lua"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
surface.CreateFont("ttt_traitor_button_font", {
	font = 'Lato',
	size = 70,
	weight = 300,
	shadow = true
})


ENT.Material = Material("tttrw/tbutton.png")
ENT.Material:SetInt("$vertexalpha", 1)
ENT.Material:SetInt("$translucent", 1)
ENT.Material:SetInt("$vertexcolor", 1)

function ENT:CL_Initialize()
	self:SetRenderBoundsWS(Vector(-56000, -56000, -56000), Vector(56000, 56000, 56000))
end

local size = 8

function ENT:DrawTranslucent()
	local me = LocalPlayer()
	if (not self:PlayerCanSee(me) or not self:IsUsable()) then
		return
	end
	--surface.SetTexture(tbut_normal)

	-- we're doing slowish distance computation here, so lots of probably
	-- ineffective micro-optimization
	local plypos = me:EyePos()

	local pos = self:GetPos()
	local scrpos = pos:ToScreen()

	if (not scrpos.visible) then
		return
	end

	local dist = plypos:Distance(self:GetPos()) / self:GetUsableRange()

	if (dist > 1) then
		return
	end

	local dir = (pos - plypos):GetNormalized()

	local dot = dir:Dot(EyeAngles():Forward())

	if (dot < 0) then
		return
	end

	local alpha = dist * 0.1 + math.max((dot - 0.85) / 0.15, 0) * 0.8 + 0.2
	
	local ang = (pos - plypos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), -90)
	cam.IgnoreZ(true)
		cam.Start3D2D(self:GetPos(), ang, 0.5)
				surface.SetDrawColor(255, 255, 255, alpha * 200)
				surface.SetMaterial(self.Material)
				surface.DrawTexturedRect(-size, -size, size * 2, size* 2)
		cam.End3D2D()
		if (self:FindUseEntity(me, NULL) == self) then
			cam.Start3D2D(self:GetPos(), ang, 0.1)
				draw.DrawText(self:GetDescription(), "ttt_traitor_button_font", 0, size * 9, white_text, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	cam.IgnoreZ(false)
end


local confirm_sound = Sound "buttons/button24.wav"
net.Receive("ttt_traitor_button", function()
	surface.PlaySound(confirm_sound)
end)