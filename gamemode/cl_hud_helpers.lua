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

function hud.BuildCurvedMesh(curve, x, y, w, h)
	local Mesh = Mesh()
	
	local curve = 6
	local function addpos(x, y)
		mesh.Position(Vector(x, y))
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

	mesh.Begin(Mesh, MATERIAL_TRIANGLES, 6 + curve * 4)
		addbox(curve, 0, w - curve * 2, h)
		addbox(0, curve, curve, h - curve * 2)
		addbox(w - curve, curve, curve, h - curve * 2)
		local lastsin, lastcos

		for i = 0, curve do
			local rad = math.rad(i / curve * 90)
			local sin, cos = math.sin(rad), math.cos(rad)

			if (lastsin) then
				addpos(curve - sin * curve, curve - cos * curve)
				addpos(curve - lastsin * curve, curve - lastcos * curve)
				addpos(curve, curve)

				addpos(w - curve + lastsin * curve, curve - lastcos * curve)
				addpos(w - curve + sin * curve, curve - cos * curve)
				addpos(w - curve, curve)

				addpos(curve - lastsin * curve, h - curve + lastcos * curve)
				addpos(curve - sin * curve, h - curve + cos * curve)
				addpos(curve, h - curve)

				addpos(w - curve + sin * curve, h - curve + cos * curve)
				addpos(w - curve + lastsin * curve, h - curve + lastcos * curve)
				addpos(w - curve, h - curve)
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