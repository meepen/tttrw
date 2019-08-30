include "shared.lua"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
surface.CreateFont("ttt_traitor_button_font", {
	font = 'Lato',
	size = ScrH() / 75,
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

function ENT:DoUse()
	RunConsoleCommand("ttt_use_tbutton", tostring(self:EntIndex()))
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

	local dot = (pos - plypos):GetNormalized():Dot(EyeAngles():Forward())

	if (dot < 0) then
		return
	end

	local alpha = dist * 0.1 + math.max((dot - 0.85) / 0.15, 0) * 0.8 + 0.2
	
	local ang = (pos - plypos):Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), -90)
	cam.Start3D2D(self:GetPos(), ang, 0.5)
		cam.IgnoreZ(true)
			surface.SetDrawColor(255, 255, 255, alpha * 200)
			surface.SetMaterial(self.Material)
			surface.DrawTexturedRect(-size, -size, size * 2, size* 2)
		cam.IgnoreZ(false)
	cam.End3D2D()

	if (self:FindUseEntity(me, NULL) ~= self) then
		return
	end

	cam.Start2D()
		local scrpos = (self:GetPos() - Vector(0, 0, size)):ToScreen()

		draw.DrawText(self:GetDescription(), "ttt_traitor_button_font", scrpos.x, scrpos.y, white_text, TEXT_ALIGN_CENTER)
	cam.End2D()
end


local confirm_sound = Sound "buttons/button24.wav"
net.Receive("ttt_traitor_button", function()
	surface.PlaySound(confirm_sound)
end)