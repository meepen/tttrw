hud = hud or {}

function hud.DrawTextShadowed(text, textcol, shadowcol, posx, posy, shadoww, shadowh)
	surface.SetTextColor(shadowcol)

	for x = 1, shadoww do
		for y = 1, shadowh do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	surface.SetTextColor(textcol)
	surface.SetTextPos(posx, posy)
	surface.DrawText(text)
end

function hud.DrawTextOutlined(text, textcol, shadowcol, posx, posy, shadowsize)
	surface.SetTextColor(shadowcol)

	--render.PushFilterMin(TEXFILTER.NONE)
	--render.PushFilterMag(TEXFILTER.NONE)
	for x = -shadowsize, -1 do
		for y = -shadowsize, -1 do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = 1, shadowsize do
		for y = -shadowsize, -1 do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = -shadowsize, -1 do
		for y = 1, shadowsize do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end

	for x = 1, shadowsize do
		for y = 1, shadowsize do
			surface.SetTextPos(posx + x, posy + y)
			surface.DrawText(text)
		end
	end
	--render.PopFilterMag()
	--render.PopFilterMin()

	surface.SetTextColor(textcol)
	surface.SetTextPos(posx, posy)
	surface.DrawText(text)
end

local function n(x, y, z)
	return x and (y or 1) or (z or 0)
end

local function Draw(self)
	for i = 1, #self do
		self[i]:Draw()
	end
end

local function Remove(self)
	for i = 1, #self do
		self[i]:Remove()
	end
end

function hud.BuildCurvedMeshOutline(curve, sx, sy, w, h, tl, tr, bl, br, clr)
	clr = clr or color_white

	tl = not tl
	tr = not tr
	bl = not bl
	br = not br

	local function addpos(x, y)
		mesh.Position(Vector(sx + x, sy + y))
		mesh.Color(clr.r, clr.g, clr.b, clr.a)
		mesh.AdvanceVertex()
	end
	local function addbox(x, y, w, h)
		addpos(x, y)
		addpos(x + w, y)
		addpos(x + w, y + h)

		addpos(x, y)
		addpos(x + w, y + h)
		addpos(x, y + h)
	end

	local curve_count = n(tl) + n(tr) + n(bl) + n(br)
	local inner = math.Round(curve / 2)

	local MainMesh = Mesh()
	local meshes = {MainMesh, Draw = Draw, Remove = Remove}

	mesh.Begin(MainMesh, MATERIAL_TRIANGLES, 8)
		addbox(n(tl, curve), 0, w - n(tl, curve) - n(tr, curve), inner)
		addbox(n(bl, curve), h - inner, w - n(br, curve) - n(bl, curve), inner)
		local hcurve = curve - inner
		addbox(0, n(tl, curve, inner), inner, h - n(tl, curve, hcurve) - n(bl, curve, hcurve))
		addbox(w - inner, n(tr, curve, inner), inner, h - n(tr, curve, hcurve) - n(br, curve, hcurve))
	mesh.End()

	if (tl) then
		local m = Mesh()
		
		mesh.Begin(m, MATERIAL_POLYGON, curve + inner + 2)
			for i = curve, 0, -1 do
				local rad = math.rad(i / curve * 90)
				addpos(curve - math.sin(rad) * curve, curve - math.cos(rad) * curve)
			end
			for i = 0, inner do
				local rad = math.rad(i / inner * 90)
				addpos(curve - math.sin(rad) * inner, curve - math.cos(rad) * inner)
			end
		mesh.End()
		meshes[#meshes + 1] = m
	end

	if (tr) then
		local m = Mesh()
		
		mesh.Begin(m, MATERIAL_POLYGON, curve + inner + 2)
			for i = 0, curve do
				local rad = math.rad(i / curve * 90)
				addpos(w - curve + math.sin(rad) * curve, curve - math.cos(rad) * curve)
			end
			for i = inner, 0, -1 do
				local rad = math.rad(i / inner * 90)
				addpos(w - curve + math.sin(rad) * inner, curve - math.cos(rad) * inner)
			end
		mesh.End()
		meshes[#meshes + 1] = m
	end

	if (bl) then
		local m = Mesh()
		
		mesh.Begin(m, MATERIAL_POLYGON, curve + inner + 2)
			for i = 0, curve do
				local rad = math.rad(i / curve * 90)
				addpos(curve - math.sin(rad) * curve, h - curve + math.cos(rad) * curve)
			end
			for i = inner, 0, -1 do
				local rad = math.rad(i / inner * 90)
				addpos(curve - math.sin(rad) * inner, h - curve + math.cos(rad) * inner)
			end
		mesh.End()
		meshes[#meshes + 1] = m
	end

	if (br) then
		local m = Mesh()
		
		mesh.Begin(m, MATERIAL_POLYGON, curve + inner + 2)
			for i = curve, 0, -1 do
				local rad = math.rad(i / curve * 90)
				addpos(w - curve + math.sin(rad) * curve, h - curve + math.cos(rad) * curve)
			end

			for i = 0, inner do
				local rad = math.rad(i / inner * 90)
				addpos(w - curve + math.sin(rad) * inner, h - curve + math.cos(rad) * inner)
			end
		mesh.End()
		meshes[#meshes + 1] = m
	end

	return meshes
end

function hud.BuildCurvedMesh(curve, sx, sy, w, h, tl, tr, bl, br, clr)
	local Mesh = Mesh()
	clr = clr or color_white

	local function addpos(x, y)
		mesh.Position(Vector(sx + x, sy + y))
		mesh.Color(clr.r, clr.g, clr.b, clr.a)
		mesh.AdvanceVertex()
	end
	local function addbox(x, y, w, h)
		addpos(x, y)
		addpos(x + w, y)
		addpos(x + w, y + h)

		addpos(x, y)
		addpos(x + w, y + h)
		addpos(x, y + h)
	end

	local curve_count = (tl and 0 or 1) + (tr and 0 or 1) + (bl and 0 or 1) + (br and 0 or 1)

	mesh.Begin(Mesh, MATERIAL_TRIANGLES, 6 + curve * curve_count)
		addbox(curve, 0, w - curve * 2, h)
		addbox(0, tl and 0 or curve, curve, h - curve * ((tl and 0 or 1) + (bl and 0 or 1)))
		addbox(w - curve, tr and 0 or curve, curve, h - curve * ((tr and 0 or 1) + (br and 0 or 1)))
		local lastsin, lastcos

		for i = 0, curve do
			local rad = math.rad(i / curve * 90)
			local sin, cos = math.sin(rad), math.cos(rad)

			if (lastsin) then
				if (not tl) then
					addpos(curve - sin * curve, curve - cos * curve)
					addpos(curve - lastsin * curve, curve - lastcos * curve)
					addpos(curve, curve)
				end

				if (not tr) then
					addpos(w - curve + lastsin * curve, curve - lastcos * curve)
					addpos(w - curve + sin * curve, curve - cos * curve)
					addpos(w - curve, curve)
				end

				if (not bl) then
					addpos(curve - lastsin * curve, h - curve + lastcos * curve)
					addpos(curve - sin * curve, h - curve + cos * curve)
					addpos(curve, h - curve)
				end

				if (not br) then
					addpos(w - curve + sin * curve, h - curve + cos * curve)
					addpos(w - curve + lastsin * curve, h - curve + lastcos * curve)
					addpos(w - curve, h - curve)
				end
			end

			lastsin, lastcos = sin, cos
		end
	mesh.End()

	return Mesh
end

local colour = Material "pp/colour"
local matrix = Matrix()
function hud.StartStenciledMesh(Mesh, x, y)
	matrix:SetTranslation(Vector(x, y))

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
		cam.PushModelMatrix(matrix)
			render.OverrideColorWriteEnable(true, false)
				Mesh:Draw()
			render.OverrideColorWriteEnable(false, false)

			render.SetStencilPassOperation(STENCIL_KEEP)
			render.SetStencilCompareFunction(STENCIL_EQUAL)
end

function hud.EndStenciledMesh()
		cam.PopModelMatrix()
	render.SetStencilEnable(false)
end