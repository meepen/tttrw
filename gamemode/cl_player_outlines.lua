local tttrw_outline_roles = CreateConVar("tttrw_outline_roles", "1", FCVAR_ARCHIVE, "See traitor buddies with outlines")
local tttrw_outline_roles_ignorez = CreateConVar("tttrw_outline_roles_ignorez", "1", FCVAR_ARCHIVE, "See traitor buddies through walls with outlines")
local tttrw_outline_roles_mult = CreateConVar("tttrw_outline_roles_mult", "1.05", FCVAR_ARCHIVE, "See traitor buddies through walls with outlines", 1, 10)

local mat = CreateMaterial("tttrw_player_outline", "VertexLitGeneric", {
	["$basetexture"]    = "color/white",
	["$model"]          = 1,
	["$translucent"]    = 1,
	["$vertexalpha"]    = 1,
	["$vertexcolor"]    = 1,
})

local incr = 0.01

local matr = Matrix()
local matr_zero = Matrix()
function GM:PostDrawOpaqueRenderables()
	if (not tttrw_outline_roles:GetBool()) then
		return
	end

	local mult = tttrw_outline_roles_mult:GetFloat()
	local scale = Vector(mult, mult, (mult - 1) / 5 + 1)
	matr:SetScale(scale)

	if (tttrw_outline_roles_ignorez:GetBool()) then
		cam.IgnoreZ(true)
	end

	local r, g, b = render.GetColorModulation()
	render.SuppressEngineLighting(true)
	render.MaterialOverride(mat)

	for _, ply in pairs(player.GetAll()) do
		local mn, mx 
		if (ply:GetRoleTeam() ~= "traitor" or not ply:Alive() or ply:IsDormant()) then
			continue
		end
		local col = ply:GetRoleData().Color
		render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)

		mn, mx = ply:GetCollisionBounds()

		matr:SetTranslation(Vector(0, 0, -(mx.z - mn.z) * (scale.z - 1) / 2))

		ply:EnableMatrix("RenderMultiply", matr)
		ply:SetupBones()

			ply:DrawModel()

		matr:SetTranslation(Vector(0, 0, (mx.z - mn.z) * (scale.z - 1) / 2))
		ply:EnableMatrix("RenderMultiply", matr)
		ply:SetupBones()

			ply:DrawModel()

		ply:DisableMatrix("RenderMultiply")
		ply:InvalidateBoneCache()
	end

	render.MaterialOverride()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(r, g, b)
	if (tttrw_outline_roles_ignorez:GetBool()) then
		cam.IgnoreZ(false)
	end

	for _, ply in pairs(player.GetAll()) do
		local mn, mx 
		if (ply:GetRoleTeam() ~= "traitor" or not ply:Alive()) then
			continue
		end

		ply:DrawModel()
	end
end