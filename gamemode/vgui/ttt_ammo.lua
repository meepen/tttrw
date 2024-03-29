local PANEL = {}

local colour = Material "models/debug/debugwhite"

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

	local lookup = wep.Ortho or {0, 0}

	local x, y = self:LocalToScreen(0, 0)
	local mins, maxs = err:GetModelBounds()
	local angle = Angle(0, -90)
	local size = mins:Distance(maxs) / 2.5 * (lookup.size or 1) * 1.1

	cam.Start3D(vector_origin, lookup.angle or angle, 90, x, y, w, h)
		cam.StartOrthoView(lookup[1] + -size, lookup[2] + size, lookup[1] + size, lookup[2] + -size)
			render.SuppressEngineLighting(true)
				err:SetAngles(Angle(-40, 10, 10))
				render.PushFilterMin(TEXFILTER.ANISOTROPIC)
				render.PushFilterMag(TEXFILTER.ANISOTROPIC)
					render.MaterialOverride(colour)
						local col = self:GetCurrentColor()
						local r, g, b = render.GetColorModulation()
						render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
							render.SetBlend(col.a / 255)
								err:DrawModel()
							render.SetBlend(1)
						render.SetColorModulation(r, g, b)
					render.MaterialOverride()
				render.PopFilterMag()
				render.PopFilterMin()
			render.SuppressEngineLighting(false)
		cam.EndOrthoView()
	cam.End3D()
end

function PANEL:OnRemove()
	if (IsValid(self.Model)) then
		self.Model:Remove()
	end
end

function PANEL:GetCurrentColor()
	return self:GetCustomizedColor(self.inputs.color) or color_white
end

vgui.Register("ttt_weapon", PANEL, "ttt_hud_customizable")