include "shared.lua"

local ttt_lowered = CreateConVar("ttt_ironsights_lowered", "1", FCVAR_ARCHIVE)

SWEP.DrawCrosshair = true
SWEP.ScopeArcTexture = Material "tttrw/scope"
SWEP.ReticleScale = 1

function SWEP:HasTFAScope()
	return not not self.Secondary.ScopeTable
end

function SWEP:DrawScopeOverlay()
	local tbl = self.Secondary.ScopeTable

	if (not tbl) then
		return
	end

	local w, h = ScrW(), ScrH()

	for k, v in pairs(tbl) do
		local dimension = h

		if k == "ScopeBorder" then
			if istable(v) then
				surface.SetDrawColor(v)
			else
				surface.SetDrawColor(color_black)
			end

			surface.DrawRect(0, 0, w / 2 - dimension / 2, dimension)
			surface.DrawRect(w / 2 + dimension / 2, 0, w / 2 - dimension / 2, dimension)
		elseif k == "ScopeMaterial" then
			surface.SetMaterial(v)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
		elseif k == "ScopeOverlay" then
			surface.SetMaterial(v)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, w, h)
		elseif k == "ScopeCrosshair" then
			local t = type(v)

			if t == "IMaterial" then
				surface.SetMaterial(v)
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawTexturedRect(w / 2 - dimension / 4, h / 2 - dimension / 4, dimension / 2, dimension / 2)
			elseif t == "table" then
				if not v.cached then
					v.cached = true
					v.r = v.r or v.x or v[1] or 0
					v.g = v.g or v.y or v[2] or v[1] or 0
					v.b = v.b or v.z or v[3] or v[1] or 0
					v.a = v.a or v[4] or 255
					v.s = v.Scale or v.scale or v.s or 0.25
				end

				surface.SetDrawColor(v.r, v.g, v.b, v.a)

				if v.Material then
					surface.SetMaterial(v.Material)
					surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
				elseif v.Texture then
					surface.SetTexture(v.Texture)
					surface.DrawTexturedRect(w / 2 - dimension * v.s / 2, h / 2 - dimension * v.s / 2, dimension * v.s, dimension * v.s)
				else
					surface.DrawRect(w / 2 - dimension * v.s / 2, h / 2, dimension * v.s, 1)
					surface.DrawRect(w / 2, h / 2 - dimension * v.s / 2, 1, dimension * v.s)
				end
			end
		elseif (k ~= "BaseClass") then
			if k == "scopetex" then
				dimension = dimension * self.ScopeScale ^ 2
			elseif k == "reticletex" then
				dimension = dimension * (self.ReticleScale and self.ReticleScale or 1) ^ 2
			else
				dimension = dimension * self.ReticleScale ^ 2
			end

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(v)
			surface.DrawTexturedRect(w / 2 - dimension / 2, (h - dimension) / 2, dimension, dimension)
		end
	end

	return true
end

function SWEP:DrawHUD()
	if (self:GetIronsights() and self.HasScope) then
		if (self:HasTFAScope()) then
			return self:DrawScopeOverlay()
		end

		-- scope arc
		surface.SetMaterial(self.ScopeArcTexture)
		local x = ScrW() / 2


		local is_ironsights = self.CurIronsights
		local toggletime = self.IronTime or 0
		local time = is_ironsights and self.Ironsights.TimeTo or self.Ironsights.TimeFrom

		local frac = math.min(1, (self:GetUnpredictedTime() - toggletime) / time)

		surface.SetDrawColor(0, 0, 0, 255)

		-- top right
		surface.DrawTexturedRectUV(x, 0, ScrH() / 2, ScrH() / 2, 0, 1, 1, 0)

		-- top left
		surface.DrawTexturedRectUV(x - ScrH() / 2, 0, ScrH() / 2, ScrH() / 2, 1, 1, 0, 0)

		-- bottom left
		surface.DrawTexturedRectUV(x - ScrH() / 2, ScrH() / 2, ScrH() / 2, ScrH() / 2, 1, 0, 0, 1)
		-- bottom right
		surface.DrawTexturedRect(x, ScrH() / 2, ScrH() / 2, ScrH() / 2)

		surface.DrawRect(0, 0, math.ceil(x - ScrH() / 2), ScrH())
		surface.DrawRect(math.floor(x + ScrH() / 2), 0, math.ceil(x - ScrH() / 2), ScrH())
	end
end

function SWEP:DoDrawCrosshair(x, y)
	if (self:GetIronsights() and self.HasScope) then
		if (self:HasTFAScope()) then
			return true
		end

		local w, h = ScrW(), ScrH()
		surface.SetDrawColor(0, 0, 0, 255)

		surface.DrawLine(x - w / 2, y, x + w / 2, y)
		surface.DrawLine(x, y - h / 2, x, y + h / 2)

		surface.SetDrawColor(255, 255, 255, 255)

		surface.DrawRect(x - 1, y - 1, 3, 3)

		return true
	end

	ttt.DefaultCrosshair(x, y, self)

	return true
end

local host_timescale = GetConVar("host_timescale")

function SWEP:GetUnpredictedTime()
	return (self.CurTime or 0) + (RealTime() - (self.RealTime or 0)) * game.GetTimeScale() * host_timescale:GetFloat()
end

local vector_lower = Vector(0, 0, 2)

function SWEP:GetIronsightsPos(is_ironsights, frac, pos, ang)
	local complete_ironpos, complete_ironang = self.Ironsights.Pos, self.Ironsights.Angle

	local ironpos, ironang = -(self.ViewModelPos or vector_origin) + complete_ironpos - (not self.PreventLowered and ttt_lowered:GetBool() and vector_lower or vector_origin), complete_ironang

	local frompos, fromang, topos, toang = vector_origin, vector_origin, ironpos, ironang
	if (not is_ironsights) then
		topos, toang, frompos, fromang = frompos, fromang, topos, toang
	end

	local newang = LerpVector(frac, fromang, toang)
	local newpos = LerpVector(frac, frompos, topos)

	ang:RotateAroundAxis(ang:Right(),   newang.x)
	ang:RotateAroundAxis(ang:Up(),      newang.y)
	ang:RotateAroundAxis(ang:Forward(), newang.z)

	pos = pos + newpos.x * ang:Right()
	          + newpos.y * ang:Forward()
			  + newpos.z * ang:Up()

	return pos, ang
end

function SWEP:GetViewModelPosition(pos, ang)
	if (self.ViewModelPos) then
		pos = pos + self.ViewModelPos
	end

	if (self.ViewModelChange) then
		local change = self.ViewModelChange
		if (change.Ang) then
			ang:RotateAroundAxis(ang:Right(),   change.Ang.x)
			ang:RotateAroundAxis(ang:Up(),      change.Ang.y)
			ang:RotateAroundAxis(ang:Forward(), change.Ang.z)
		end

		if (change.Pos) then
			pos = pos + change.Pos.x * ang:Right()
					  + change.Pos.y * ang:Forward()
					  + change.Pos.z * ang:Up()
		end
	end

	if (self.NoSights or not self.Ironsights or self.CurIronsights == nil) then
		return pos, ang
	end

	local is_ironsights = self.CurIronsights
	local toggletime = self.IronTime or 0
	local time = is_ironsights and self.Ironsights.TimeTo or self.Ironsights.TimeFrom

	local frac = math.min(1, (self:GetUnpredictedTime() - toggletime) / time) ^ 1.3

	pos, ang = self:GetIronsightsPos(is_ironsights, frac, pos, ang)

	if (is_ironsights) then
		self.SwayScale = 0.2
		self.BobScale = 0.07
	else
		self.SwayScale = 1
		self.BobScale = 1
	end

	if (IsValid(self:GetOwner()) and self:GetOwner():Alive()) then
		ang = ang - self:GetOwner():GetViewPunchAngles()
	end

	ang = ang + self:GetCurrentUnpredictedViewPunch()

	if (not self:GetIronsights()) then
		local diff = self:GetUnpredictedTime() - self:GetRealLastShootTime()
		local frac = diff / self:GetDelay()
		local backwards = 1
		local upwards = 1.5
		if (frac < 0.15) then
			frac = frac / 0.15
			ang = ang + Angle(-upwards * frac)
			pos = pos - ang:Forward() * backwards * frac
		elseif (frac < 2) then
			frac = 1 - (frac - 0.15) / 1.85
			ang = ang + Angle(-upwards * frac)
			pos = pos - ang:Forward() * backwards * frac
		end
	end

	return pos, ang
end

function SWEP:GetCurrentUnpredictedFOVMultiplier()
	local fov, time, duration = self.FOVMultiplier or 1, self.FOVMultiplierTime or -0.1, self.FOVMultiplierDuration or 0.1
	local ofov = self.OldFOVMultiplier or 1

	local cur = math.min(1, (self:GetUnpredictedTime() - time) / duration)

	local res = ofov + (fov - ofov) * cur ^ 0.9

	if (self:GetOwner() ~= LocalPlayer()) then
		return math.sqrt(res)
	end

	return res
end

function SWEP:TranslateFOV(fov)
	return (hook.Run("TTTGetFOV", fov) or fov) * self:GetCurrentUnpredictedFOVMultiplier()
end

local quat_zero = Quaternion()

function SWEP:GetCurrentUnpredictedViewPunch()
	local delay = self.Primary.RecoilTiming or self.Primary.Delay
	local time = self._ViewPunchTime or -math.huge
	local frac = (self:GetUnpredictedTime() - time) / delay

	if (frac >= 1) then
		return angle_zero
	end

	local vp = self._ViewPunch or angle_zero
	local diff = Quaternion():SetEuler(-vp):Slerp(quat_zero, frac):ToEulerAngles()

	return diff
end

function SWEP:CalcView(ply, pos, ang, fov)
	local delay = self.Primary.Delay * 2

	return pos, ang + self:GetCurrentUnpredictedViewPunch() - ply:GetViewPunchAngles(), fov
end

function SWEP:CalcViewPunch()
	self._ViewPunch = self:GetViewPunch()
	self._ViewPunchTime = self:GetViewPunchTime()
end

function SWEP:CalcFOV()
	self.FOVMultiplier = self:GetFOVMultiplier()
	self.FOVMultiplierTime = self:GetFOVMultiplierTime()
	self.FOVMultiplierDuration = self:GetFOVMultiplierDuration()
	self.OldFOVMultiplier = self:GetOldFOVMultiplier()
end

function SWEP:CalcUnpredictedTimings()
	self.CurTime = CurTime()
	self.RealTime = RealTime()
end

function SWEP:CalcViewModel()
	self.CurIronsights = self:GetIronsights()
	self.IronTime = self:GetIronsightsTime()
end

function SWEP:CalcAllUnpredicted(force)
	if (not IsFirstTimePredicted() or force) then
		return
	end

	self:CalcUnpredictedTimings()
	self:CalcViewPunch()
	self:CalcViewModel()
	self:CalcFOV()
end

function SWEP:DrawWorldModel()
    local hand, offset, rotate
    local pl = self:GetParent()

    if (IsValid(pl) and pl.SetupBones) then
        pl:SetupBones()
        pl:InvalidateBoneCache()
        self:InvalidateBoneCache()
	end


    if (IsValid(pl) and self.Offset) then
        local boneIndex = pl:LookupBone "ValveBiped.Bip01_R_Hand"

        if boneIndex then
            local pos, ang

            local mat = pl:GetBoneMatrix(boneIndex)
            if mat then
                pos, ang = mat:GetTranslation(), mat:GetAngles()
            else
                pos, ang = pl:GetBonePosition(handBone)
            end

            pos = pos + ang:Forward() * self.Offset.Pos.Forward + ang:Right() * self.Offset.Pos.Right + ang:Up() * self.Offset.Pos.Up
            ang:RotateAroundAxis(ang:Up(), self.Offset.Ang.Up)
            ang:RotateAroundAxis(ang:Right(), self.Offset.Ang.Right)
            ang:RotateAroundAxis(ang:Forward(), self.Offset.Ang.Forward)
            self:SetRenderOrigin(pos)
            self:SetRenderAngles(ang)
            self:DrawModel()
        end
    else
        self:SetRenderOrigin(nil)
        self:SetRenderAngles(nil)
        self:DrawModel()
	end
	
	self:DrawExtraModels()
end

concommand.Remove "gmod_undo"

SWEP.vRenderOrder = nil
function SWEP:ViewModelDrawn()
	local owner = self:GetOwner()
	local vm = owner:GetViewModel()
	if (not IsValid(vm)) then return end

	if (not self.VElements) then
		return
	end

	self:UpdateBonePositions(vm)

	if (not self.vRenderOrder) then

		-- // we build a render order because sprites need to be drawn after models
		self.vRenderOrder = {}

		for k, v in pairs(self.VElements) do
			if (v.type == "Model") then
				table.insert(self.vRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.vRenderOrder, k)
			end
		end

	end

	for k, name in ipairs(self.vRenderOrder) do
		local v = self.VElements[name]
		if (not v) then
			self.vRenderOrder = nil
			break
		end

		if (v.hide) then
			continue
		end

		local model = v.modelEnt
		local sprite = v.spriteMaterial

		if (not v.bone) then
			continue
		end

		local pos, ang = self:GetBoneOrientation(self.VElements, v, vm)

		if (not pos) then continue end

		if (v.type == "Model" and IsValid(model)) then
			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)

			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if (v.material == "") then
				model:SetMaterial ""
			elseif (model:GetMaterial() ~= v.material) then
				model:SetMaterial(v.material)
			end

			if (v.skin and v.skin ~= model:GetSkin()) then
				model:SetSkin(v.skin)
			end

			if (v.bodygroup) then
				for k, v in pairs(v.bodygroup) do
					if (model:GetBodygroup(k) ~= v) then
						model:SetBodygroup(k, v)
					end
				end
			end

			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r / 255, v.color.g / 255, v.color.b / 255)
			render.SetBlend(v.color.a / 255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end

		elseif (v.type == "Sprite" and sprite) then

			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

		elseif (v.type == "Quad" and v.draw_func) then

			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
			cam.End3D2D()

		end
	end
end

function SWEP:UpdateBonePositions(vm)
	if (self.ViewModelBoneMods) then
		if (not vm:GetBoneCount()) then return end

		-- // !! WORKAROUND !! --//
		-- // We need to check all model names :/
		local loopthrough = self.ViewModelBoneMods
		if (not hasGarryFixedBoneScalingYet) then
			allbones = {}
			for i=0, vm:GetBoneCount() do
				local bonename = vm:GetBoneName(i)
				if (self.ViewModelBoneMods[bonename]) then 
					allbones[bonename] = self.ViewModelBoneMods[bonename]
				else
					allbones[bonename] = { 
						scale = Vector(1,1,1),
						pos = Vector(0,0,0),
						angle = Angle(0,0,0)
					}
				end
			end

			loopthrough = allbones
		end

		for k, v in pairs(loopthrough) do
			local bone = vm:LookupBone(k)
			if (not bone) then
				continue
			end

			-- // !! WORKAROUND !! --//
			local s = Vector(v.scale.x,v.scale.y,v.scale.z)
			local p = Vector(v.pos.x,v.pos.y,v.pos.z)
			local ms = Vector(1,1,1)
			if (not hasGarryFixedBoneScalingYet) then
				local cur = vm:GetBoneParent(bone)
				while (cur >= 0) do
					local pscale = loopthrough[vm:GetBoneName(cur)].scale
					ms = ms * pscale
					cur = vm:GetBoneParent(cur)
				end
			end

			s = s * ms

			if (vm:GetManipulateBoneScale(bone) ~= s) then
				vm:ManipulateBoneScale(bone, s)
			end
			if (vm:GetManipulateBoneAngles(bone) ~= v.angle) then
				vm:ManipulateBoneAngles(bone, v.angle)
			end
			if (vm:GetManipulateBonePosition(bone) ~= p) then
				vm:ManipulateBonePosition(bone, p)
			end
		end
	else
		self:ResetBonePositions(vm)
	end
end

function SWEP:ResetBonePositions(vm)
	if (not vm:GetBoneCount()) then
		return
	end
	for i = 0, vm:GetBoneCount() do
		vm:ManipulateBoneScale(i, Vector(1, 1, 1))
		vm:ManipulateBoneAngles(i, Angle(0, 0, 0))
		vm:ManipulateBonePosition(i, Vector(0, 0, 0))
	end
end


function SWEP:GetBoneOrientation(basetab, tab, ent, bone_override)

	local bone, pos, ang
	if (tab.rel and tab.rel ~= "") then
		local v = basetab[tab.rel]

		if (not v) then
			return
		end

		-- // Technically, if there exists an element with the same name as a bone
		-- // you can get in an infinite loop. Let's just hope nobody's that stupid.
		pos, ang = self:GetBoneOrientation(basetab, v, ent)

		if (not pos) then
			return
		end

		pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
		ang:RotateAroundAxis(ang:Up(), v.angle.y)
		ang:RotateAroundAxis(ang:Right(), v.angle.p)
		ang:RotateAroundAxis(ang:Forward(), v.angle.r)
	else
		bone = ent:LookupBone(bone_override or tab.bone)

		if (not bone) then
			return
		end

		pos, ang = Vector(0,0,0), Angle(0,0,0)
		local m = ent:GetBoneMatrix(bone)
		if (m) then
			pos, ang = m:GetTranslation(), m:GetAngles()
		end

		if (IsValid(self.Owner) and self.Owner:IsPlayer() and 
			ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
			ang.r = -ang.r --// Fixes mirrored models
		end
	end
	return pos, ang
end


SWEP.wRenderOrder = nil
function SWEP:DrawExtraModels()
	local owner = self:GetOwner()
	if (LocalPlayer() ~= owner and ttt.GetHUDTarget() == owner) then
		return
	end

	if (self.ShowWorldModel == nil or self.ShowWorldModel) then
		self:DrawModel()
	end

	if (!self.WElements) then return end

	if (!self.wRenderOrder) then

		self.wRenderOrder = {}

		for k, v in pairs(self.WElements) do
			if (v.type == "Model") then
				table.insert(self.wRenderOrder, 1, k)
			elseif (v.type == "Sprite" or v.type == "Quad") then
				table.insert(self.wRenderOrder, k)
			end
		end

	end

	if (IsValid(self.Owner)) then
		bone_ent = self.Owner
	else
		-- // when the weapon is dropped
		bone_ent = self
	end

	for k, name in pairs(self.wRenderOrder) do

		local v = self.WElements[name]
		if (!v) then self.wRenderOrder = nil break end
		if (v.hide) then continue end

		local pos, ang

		if (v.bone) then
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent)
		else
			pos, ang = self:GetBoneOrientation(self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand")
		end

		if (!pos) then continue end

		local model = v.modelEnt
		local sprite = v.spriteMaterial

		if (v.type == "Model" and IsValid(model)) then

			model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z)
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			model:SetAngles(ang)
			-- //model:SetModelScale(v.size)
			local matrix = Matrix()
			matrix:Scale(v.size)
			model:EnableMatrix("RenderMultiply", matrix)

			if (v.material == "") then
				model:SetMaterial ""
			elseif (model:GetMaterial() ~= v.material) then
				model:SetMaterial(v.material)
			end

			if (v.skin and v.skin ~= model:GetSkin()) then
				model:SetSkin(v.skin)
			end

			if (v.bodygroup) then
				for k, v in pairs(v.bodygroup) do
					if (model:GetBodygroup(k) ~= v) then
						model:SetBodygroup(k, v)
					end
				end
			end

			if (v.surpresslightning) then
				render.SuppressEngineLighting(true)
			end

			render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
			render.SetBlend(v.color.a/255)
			model:DrawModel()
			render.SetBlend(1)
			render.SetColorModulation(1, 1, 1)

			if (v.surpresslightning) then
				render.SuppressEngineLighting(false)
			end

		elseif (v.type == "Sprite" and sprite) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			render.SetMaterial(sprite)
			render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
		elseif (v.type == "Quad" and v.draw_func) then
			local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

			cam.Start3D2D(drawpos, ang, v.size)
				v.draw_func(self)
			cam.End3D2D()
		end
	end
end

local viewmodel_fov = GetConVar "viewmodel_fov"

function SWEP:PreDrawViewModel()
	if (not self.RealViewModelFOV) then
		self.RealViewModelFOV = self.ViewModelFOV
	end

	self.ViewModelFOV = self.RealViewModelFOV * (viewmodel_fov:GetFloat() / viewmodel_fov:GetDefault())
end