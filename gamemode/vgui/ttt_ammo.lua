local PANEL = {}

function PANEL:Init()
	self:AddFunction("ttt", "ready", function()
		self.Ready = true
	end)
	
	self:SetHTML [[
<head>
	<link href='http://fonts.googleapis.com/css?family=Lato:400,700' rel='stylesheet' type='text/css'>
	<style>
		* {
			-webkit-font-smoothing: antialiased;
			-moz-osx-font-smoothing: grayscale;
			line-height: 15px;
		}
		h1 {
			font-size: 30px;
			font-family: 'Lato', sans-serif;
			text-align: center;
			text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
			color: #F7F7F7;
		}
		h2 {
			font-size: 23px;
			font-family: 'Lato', sans-serif;
			text-align: center;
			text-shadow: 2px 1px 1px rgba(0, 0, 0, .4);
			color: #F7F7F7;
		}
		.shadow {
		  -webkit-filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
		  filter: drop-shadow( 1px 1px 1px rgba(0, 0, 0, .7));
		}
	</style>
</head>
<body onload="ttt.ready()">
	<h1 id="ammoCounter" class="shadow" />
	<h2 id="reserveAmmo" class="shadow" />
	<script>
		var ammoCounter = document.getElementById("ammoCounter");
		var reserveAmmo = document.getElementById("reserveAmmo");
		
		
		var ammo = 0;
		var maxAmmo = 0;
		
		
		function setAmmo(_ammo)
		{
			ammo = _ammo
			
			ammoCounter.innerHTML = _ammo + "/" + maxAmmo
		}
		
		function setMaxAmmo(_maxAmmo)
		{
			maxAmmo = _maxAmmo
			
			ammoCounter.innerHTML = ammo + "/" + _maxAmmo
		}
		
		function setAllAmmo(_ammo, _maxAmmo, _reserve)
		{
			ammo = _ammo
			maxAmmo = _maxAmmo
			
			ammoCounter.innerHTML = _ammo + "/" + _maxAmmo
			reserveAmmo.innerHTML = _reserve
		}
		
		function setReserveAmmo(_reserve)
		{
			reserveAmmo.innerHTML = _reserve
		}
	</script>
</body>
	]]
	
	self.OldAmmo = 0
	self.ReserveAmmo = 0

	hook.Add("PlayerSwitchWeapon", self, self.PlayerSwitchWeapon)
end

function PANEL:OnRemove()
	timer.Destroy("ttt_ammo_timer")
end

function PANEL:UpdateAllAmmo(pl, wep)
	if (not IsValid(wep)) then return end
	
	local max_bullets = wep.Primary and wep.Primary.ClipSize or wep:Clip1()
	local cur_bullets = wep:Clip1()
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	
	self.OldAmmo = cur_bullets
	self.ReserveAmmo = reserve
	
	self:CallSafe([[setAllAmmo("%s", "%s", "%s")]], cur_bullets, max_bullets, reserve)
end

function PANEL:PlayerSwitchWeapon(pl, old, new)
	if (not IsFirstTimePredicted()) then
		return
	end

	if (pl ~= self:GetTarget()) then return end

	if (IsValid(self.Model)) then
		self.Model:Remove()
	end

	if (IsValid(new)) then
		self.Model = ClientsideModel(new.WorldModel, RENDERGROUP_OTHER)
	end

	self:UpdateAllAmmo(pl, new)
end

function PANEL:PerformLayout()
	self:SetPos(ScrW() * 0.85625, ScrH() * 0.777)
	self:SetSize(ScrW() * 0.125, ScrH() * 0.2)

	local pl = self:GetTarget()
	self:UpdateAllAmmo(pl, pl:GetActiveWeapon())
	
	timer.Create("ttt_ammo_timer", 0.1, 0, function() self:Tick() end)
end

function PANEL:Tick()
	if (not self.Ready) then return end
	
	local pl = self:GetTarget()
	local wep = pl:GetActiveWeapon()
	if (not IsValid(wep)) then return end

	local cur_bullets = wep:Clip1()
	if (self.OldAmmo ~= cur_bullets) then
		self.OldAmmo = cur_bullets
		self:CallSafe([[setAmmo("%s")]], cur_bullets)
	end
	
	local reserve = pl:GetAmmoCount(wep:GetPrimaryAmmoType())
	if (self.ReserveAmmo ~= reserve) then
		self.ReserveAmmo = reserve
		self:CallSafe([[setReserveAmmo("%s")]], reserve)
	end
end

local err = ClientsideModel("models/weapons/w_rif_ak47.mdl", RENDERGROUP_OTHER)
local colour = Material "pp/colour"

function PANEL:Paint(w, h)

	local targ = self:GetTarget()
	if (not IsValid(targ)) then
		return
	end

	local wep = targ:GetActiveWeapon()

	if (not IsValid(wep)) then
		return
	end

	local err = self.Model
	if (not IsValid(err)) then
		return
	end

	local x, y = self:LocalToScreen(0, 30)
	cam.Start3D(vector_origin, angle_zero, 90, x, y, w, h - 30)
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

vgui.Register("ttt_ammo", PANEL, "ttt_html_base")
