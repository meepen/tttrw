local PANEL = {}

local colour = Material "pp/colour"

function PANEL:Paint(w, h)
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return
	end

	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep) or not wep.WorldModel) then
		return
	end

	if (wep ~= self.LastWeapon) then
		if (IsValid(self.Model)) then
			self.Model:Remove()
		end
		self.Model = ClientsideModel(wep.WorldModel, RENDERGROUP_OTHER)
		self.Model:SetNoDraw(true)
		self.LastWeapon = wep
	end

	local err = self.Model
	if (not IsValid(err)) then
		return
	end

	local x, y = self:LocalToScreen(0, 0)
	cam.Start3D(vector_origin, angle_zero, 90, x, y, w, h)
		render.SuppressEngineLighting(true)
			local renderpos, renderang = wep:GetRenderOrigin(), wep:GetRenderAngles()
			err:SetRenderOrigin(Vector(25, 0, 0))
			err:SetRenderAngles(Angle(0, 90, 0))

				render.SetStencilWriteMask(1)
				render.SetStencilTestMask(1)
				render.SetStencilReferenceValue(1)
				render.SetStencilCompareFunction(STENCIL_ALWAYS)
				render.SetStencilPassOperation(STENCIL_REPLACE)
				render.SetStencilFailOperation(STENCIL_KEEP)
				render.SetStencilZFailOperation(STENCIL_KEEP)
				render.ClearStencil()

				render.SetStencilEnable(true)
				render.SetMaterial(colour)
					render.OverrideColorWriteEnable(true, false)
						err:DrawModel()
					render.OverrideColorWriteEnable(false, false)

					render.SetStencilPassOperation(STENCIL_KEEP)
					render.SetStencilCompareFunction(STENCIL_EQUAL)

					render.SetColorMaterial()
					render.DrawScreenQuad()
				render.SetStencilEnable(false)

			err:SetRenderOrigin(renderpos)
			err:SetRenderAngles(renderang)
		render.SuppressEngineLighting(false)
	cam.End3D()
end

function PANEL:OnRemove()
	if (IsValid(self.Model)) then
		self.Model:Remove()
	end
end

vgui.Register("ttt_ammo_weapon", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()

	self.Model = self:Add "ttt_ammo_weapon"
	self.Model:Dock(FILL)

	self.Big = self:Add "DLabel"
	self.Smol = self:Add "DLabel"
	self:InvalidateLayout(true)

	self.Big:SetFont "ttt_ammo_font_large"
	self.Big:SetContentAlignment(5)
	self.Big:SetText ""
	self.Big:Dock(TOP)

	self.Smol:SetFont "ttt_ammo_font_smol"
	self.Smol:SetContentAlignment(5)
	self.Smol:Dock(TOP)
	self.Smol:SetText ""
end

function PANEL:Think()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return
	end

	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep) or not wep.Primary) then
		return
	end

	if (wep.Primary.ClipSize == -1) then
		self.Big:SetText ""
		self.Smol:SetText ""
	else
		self.Big:SetText(string.format("%i / %i", wep:Clip1(), wep:GetMaxClip1()))
		self.Smol:SetText(targ:GetAmmoCount(wep:GetPrimaryAmmoType()))
	end
end

function PANEL:PerformLayout(w, h)
	surface.CreateFont("ttt_ammo_font_large", {
        font = "Lato",
        size = self:GetTall() * 0.2,
		weight = 1000
	})
	self.Big:SetTall(self:GetTall() * 0.2)
	surface.CreateFont("ttt_ammo_font_smol", {
        font = "Lato",
        size = self:GetTall() * 0.12,
		weight = 1000
    })
	self.Smol:SetTall(self:GetTall() * 0.12)
end

vgui.Register("ttt_ammo", PANEL, "ttt_hud_customizable")
