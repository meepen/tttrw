SWEP.Author = "Meepen"
SWEP.Instructions = "Use this as a base weapon."
SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.UseHands = true

SWEP.ReloadAnimation = ACT_VM_RELOAD

DEFINE_BASECLASS "weapon_base"

SWEP.MuzzleAttachment = "muzzle"

SWEP.Primary.Automatic   = true
SWEP.Primary.Delay       = 0.1
SWEP.Primary.DefaultClip = 100000
SWEP.Primary.ClipSize    = 32
SWEP.Primary.Damage      = 20

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Sound = false
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.DefaultClip = 0

SWEP.Secondary.Delay     = 0.1
SWEP.ReloadSpeed         = 1

SWEP.HeadshotMultiplier  = 2
SWEP.PropForce = 1
SWEP.DeploySpeed = 1

SWEP.DeployAnim = ACT_VM_DRAW

SWEP.Bullets = {
	HullSize = 0,
	Num = 1,
	DamageDropoffRange = 600,
	DamageDropoffRangeMax = 3600,
	DamageMinimumPercent = 0.1,
	Spread = Vector(0, 0, 0)
}

SWEP.Ironsights = {
	Pos = Vector(-8, 4, 3.9),
	Angle = Vector(0, 0, 1.5),
	TimeTo = 0.01,
	TimeFrom = 2,
	Zoom = 1,
}

SWEP.VElements = {}
SWEP.WElements = {}

SWEP.AllowDrop = true

local tttrw_toggle_ads = CLIENT and CreateConVar("tttrw_toggle_ads", "0", FCVAR_USERINFO + FCVAR_ARCHIVE, "Toggle ADS on mouse2 instead of hold to ADS")

function SWEP:IsToggleADS()
	local owner = self:GetOwner()
	return (SERVER and IsValid(owner) and owner:GetInfoNum("tttrw_toggle_ads", 0) or tttrw_toggle_ads:GetInt()) ~= 0 
end

function SWEP:NetworkVarNotifyCallback(name, old, new)
	-- printf("%s::%s %s -> %s", self:GetClass(), name, old, new)
end

function SWEP:NetVar(name, type, default, notify)
	if (not self.NetVarTypes) then
		self.NetVarTypes = {}
	end

	local id = self.NetVarTypes[type] or 0
	self.NetVarTypes[type] = id + 1
	self:NetworkVar(type, id, name)

	if (default ~= nil) then
		self["Set"..name](self, default)
	end

	if (notify) then
		self:NetworkVarNotify(name, self.NetworkVarNotifyCallback)
	end
end

local scales = {
	[HITGROUP_LEFTARM] = 0.7,
	[HITGROUP_RIGHTARM] = 0.7,
	[HITGROUP_LEFTLEG] = 0.7,
	[HITGROUP_RIGHTLEG] = 0.7,
	[HITGROUP_GEAR] = 0
}

function SWEP:GetHitgroupScale(hg)
	if (hg == HITGROUP_HEAD) then
		return self.HeadshotMultiplier or 1
	end
	return scales[hitgroup] or 1
end

function SWEP:ScaleDamage(hitgroup, dmg)
	dmg:ScaleDamage(self:GetHitgroupScale(hitgroup))
end

function SWEP:SetupDataTables()
	self:NetVar("Ironsights", "Bool", false)
	self:NetVar("IronsightsTime", "Float", 0)
	self:NetVar("FOVMultiplier", "Float", 1)
	self:NetVar("OldFOVMultiplier", "Float", 1)
	self:NetVar("FOVMultiplierTime", "Float", -0.1)
	self:NetVar("FOVMultiplierDuration", "Float", 0.1)
	self:NetVar("ViewPunch", "Angle", angle_zero)
	self:NetVar("ViewPunchTime", "Float", -math.huge)
	self:NetVar("RealLastShootTime", "Float", -math.huge)
	self:NetVar("ConsecutiveShots", "Int", 0)
	self:NetVar("BulletsShot", "Int", 0)
	self:NetVar("ReloadEndTime", "Float", math.huge)
	self:NetVar("ReloadStartTime", "Float", math.huge)
	hook.Run("TTTInitWeaponNetVars", self)
end

function SWEP:Initialize()
	hook.Run("TTTWeaponInitialize", self)
	self:SetDeploySpeed(4)
	if (SERVER) then
		self:SV_Initialize()
	else
		self.VElements = table.Copy(self.VElements)
		self.WElements = table.Copy(self.WElements)

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)
	end
	self:SetHoldType(self.HoldType)
end

function SWEP:ChangeIronsights(on)
	if (not self.Ironsights) then
		return
	end

	if (self:GetIronsights() == on) then
		return
	end

	self:SetIronsights(not self:GetIronsights())

	local old, new
	if (self:GetIronsights()) then
		old, new = self:GetIronsightsTimeFrom(), self:GetIronsightsTimeTo()
	else
		new, old = self:GetIronsightsTimeFrom(), self:GetIronsightsTimeTo()
	end

	local frac = math.min(1, (CurTime() - self:GetIronsightsTime()) / old) * new

	self:SetIronsightsTime(CurTime() - new + frac)

	if (CLIENT and IsFirstTimePredicted()) then
		self:CalcViewModel()
	end

	self:DoZoom(self:GetIronsights())
end

function SWEP:DoZoom(state)
	if (not self.Ironsights) then
		return
	end

	if (state) then
		if (self.HasScope and self.Secondary.Sound) then
			self:EmitSound(self.Secondary.Sound)
		end
		self:ChangeFOVMultiplier(self.Ironsights.Zoom, self:GetIronsightsTimeTo())
	elseif (self.HasScope) then
		self:ChangeFOVMultiplier(1, 0)
	else
		self:ChangeFOVMultiplier(1, self:GetIronsightsTimeFrom())
	end
end

function SWEP:Deploy()
	self:ChangeIronsights(false)
	self:SetIronsightsTime(0)
	self:SetOldFOVMultiplier(1)
	self:SetFOVMultiplier(1)
	if (CLIENT) then
		self:CalcFOV()
	end
	if (IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetHands())) then
		self:GetOwner():GetHands():SetNoDraw(not self.UseHands)
	end
	self:SendWeaponAnim(self.DeployAnim)

	local speed = self.DeploySpeed

	self:SetPlaybackRate(speed)
	if (IsValid(self:GetOwner())) then
		self:GetOwner():GetViewModel():SetPlaybackRate(speed)
	end

	local duration = self:SequenceDuration()

	if (speed > 0) then
		duration = duration / speed
	else
		duration = duration * speed
	end

	self:SetNextPrimaryFire(CurTime() + duration)

	if (CLIENT) then
		self:StartClientsideAnimation()
	end

	return true
end

function SWEP:GetReloadAnimation()
	return self.ReloadAnimation
end

function SWEP:CanReload()
	return not self.NoReload
end

function SWEP:GetReserveAmmo()
	return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
end

function SWEP:Reload()
	if (not self:CanReload()) then
		return
	end

	if (self:GetReloadEndTime() ~= math.huge or self:Clip1() == self:GetMaxClip1() or self:GetReserveAmmo() <= 0) then
		return
	end
	self:ChangeIronsights(false)
	if (CLIENT) then
		self:CalcFOV()
	end
	self:DoReload(self:GetReloadAnimation())
end

function SWEP:SecondaryAttack()
	if (self:IsToggleADS()) then
		self:ChangeIronsights(not self:GetIronsights())
	else
		self:ChangeIronsights(true)
	end
end

function SWEP:GetDeveloperMode()
	return false
end

function SWEP:OnDrop()
	self:SetIronsightsTime(CurTime() - self:GetIronsightsTimeFrom())
	self:SetIronsights(false)
	self:DoZoom(false)
end

function SWEP:DoDamageDropoff(tr, dmginfo)
	local distance = tr.HitPos:Distance(tr.StartPos)
	local dropoff = self:GetDamageDropoffRange()
	local max = self:GetDamageDropoffRangeMax()
	local min = self:GetDamageMinimumPercent()

	if (distance > dropoff) then
		local pct = math.min(1, (distance - dropoff) / (max - dropoff))
		dmginfo:ScaleDamage(1 - pct * (1 - min))
	end
end

function SWEP:FireBulletsCallback(tr, dmginfo, data)
	local bullet = dmginfo:GetInflictor().Bullets

	-- hitbox penetration
	if (not tr.HitregCallback and tr.Entity and tr.Entity:IsPlayer()) then
		local ply = tr.Entity
		local set = ply:GetHitboxSet()
		tr.HitGroup = ply:GetHitBoxHitGroup(tr.HitBox, set)
		local curscale = self:GetHitgroupScale(tr.HitGroup)

		for hitbox = 0, ply:GetHitBoxCount(set) - 1 do
			local group = ply:GetHitBoxHitGroup(hitbox, set)
			-- check if better scale
			local scale = self:GetHitgroupScale(group)
			if (scale < curscale) then
				continue
			end

			local bone = ply:GetHitBoxBone(hitbox, set)
			if (not bone) then
				continue
			end

			local origin, angles = ply:GetBonePosition(bone)
			local mins, maxs = ply:GetHitBoxBounds(hitbox, set)

			-- check if hit
			local hitpos = util.IntersectRayWithOBB(tr.StartPos, tr.StartPos + tr.Normal * 0xFFFF, origin, angles, mins, maxs)

			if (not hitpos) then
				continue
			end


			tr.HitPos = hitpos
			tr.HitGroup = group
			tr.HitBox = hitbox
			curscale = scale
		end
	end

	dmginfo:SetDamageCustom(tr.HitGroup)
	if (tr.HitGroup == HITGROUP_GEAR) then
		dmginfo:SetDamage(0)
	else
		self:ScaleDamage(tr.HitGroup, dmginfo)
		self:DoDamageDropoff(tr, dmginfo)
	end
end

local vector_origin = vector_origin

function SWEP:ShootBullet(data)
	local owner = self:GetOwner()

	local last_shoot = self:GetRealLastShootTime()

	self:SetRealLastShootTime(CurTime())

	owner:LagCompensation(true)
	local shot = self:DoFireBullets(nil, nil, data, last_shoot)
	owner:LagCompensation(false)

	if (IsValid(self.Owner)) then
		self:ShootEffects()
		if (CLIENT) then
			self:MuzzleEffects()
		end
	end

	return shot or 1
end

function SWEP:GetPrimaryAttackAnimation()
	return ACT_VM_PRIMARYATTACK
end

function SWEP:ShootEffects()
	self:SendWeaponAnim(self:GetPrimaryAttackAnimation())
	self.Owner:MuzzleFlash()
	self.Owner:SetAnimation(PLAYER_ATTACK1)
end

function SWEP:GetBulletDistance()
	return self.Bullets and self.Bullets.Distance or nil
end

function SWEP:AddOwnerFilter(filter)
	if (not IsValid(self:GetOwner())) then
		return filter
	end

	return player_manager.RunClass(self:GetOwner(), "AddHitFilter", filter)
end

function SWEP:DoFireBullets(src, dir, data, last_shoot)
	local bullet_info = self.Bullets
	local owner = self:GetOwner()

	src = src or owner:GetShootPos()
	dir = dir or owner:EyeAngles():Forward()
	local force = 2 / math.max(bullet_info.Num / 2, 1)

	local ignore = {}
	if (data and data.IgnoreEntity) then
		if (istable(data.IgnoreEntity)) then
			for _, v in pairs(data.IgnoreEntity) do
				ignore[_] = v
			end
		else
			ignore[1] = data.IgnoreEntity
		end
	end

	ignore = self:AddOwnerFilter(ignore)

	local shot = 1

	if (self:GetConsecutiveShots() > 0) then
		local interval = engine.TickInterval()
		local delay = self:GetDelay()
		local shot = self:GetConsecutiveShots()
		local diff = math.floor(delay / interval * shot) - math.floor(delay / interval * (shot - 1))
		shot = shot + diff
	end

	local bullets = {
		Num = bullet_info.Num * shot,
		Attacker = owner,
		Damage = self:GetDamage(),
		Tracer = 0,
		TracerName = self:GetTracerName(),
		Spread = self:GetSpread(),
		HullSize = bullet_info.HullSize,
		Force = self.PropForce,
		Callback = function(atk, tr, dmg)
			if (IsValid(self)) then
				self:FireBulletsCallback(tr, dmg, data)
				self:TracerEffect(tr, dmg)
			end
		end,
		Distance = self:GetBulletDistance(),
		Src = src,
		Dir = dir,
		IgnoreEntity = ignore[1] -- todo(meep): Facepunch/garrysmod-requests#969
	}

	self.LastBullets = table.Copy(bullets)

	self:FireBullets(bullets)

	self:SetBulletsShot(self:GetBulletsShot() + shot)

	return shot
end

function SWEP:TracerEffect(tr, dmg)
	if ((not CLIENT or IsFirstTimePredicted()) and self:GetTracers() ~= 0 and self:GetBulletsShot() % self:GetTracers() == 0) then
		local d = EffectData()
		d:SetScale(4000)
		d:SetFlags(0)
		d:SetStart(tr.StartPos)
		d:SetOrigin(tr.HitPos or tr.StartPos)
		d:SetDamageType(dmg:GetDamageType())
		d:SetColor(1)
		d:SetEntity(self)

		local att = self:LookupAttachment(self.MuzzleAttachment)

		if (att ~= -1) then
			d:SetAttachment(att)
		end

		local r
		if (SERVER) then
			r = RecipientFilter()
			r:AddAllPlayers()
		end
		util.Effect(self:GetTracerName(), d, true, r)
	end
end

function SWEP:GetMultiplier()
	return 1
end

function SWEP:GetConsecutiveShots()
	return 0
end

function SWEP:GetSpread()
	return self.Bullets.Spread * (self.Primary.Ammo:lower() == "buckshot" and 1 or (0.25 + (-self:GetMultiplier() + 2) * 0.75)) * (0.5 + self:GetCurrentZoom() / 2) ^ 0.7
end

function SWEP:CanPrimaryAttack()
	if (self:Clip1() > 0) then
		return true
	end
	return false
end

function SWEP:PrimaryAttack()
	if (not self:CheckBeforeFire()) then
		return
	end

	local interval = engine.TickInterval()
	local delay = math.ceil(self:GetDelay() / interval) * interval
	local diff = (CurTime() - self:GetRealLastShootTime()) / delay

	-- do this before consecutive
	self:SetNextPrimaryFire(CurTime() + self:GetDelay())

	if (diff <= 1.25) then
		self:SetConsecutiveShots(self:GetConsecutiveShots() + 1)
	else
		self:SetConsecutiveShots(0)
	end

	self:StartShoot()
end

-- for burst guns
function SWEP:StartShoot()
	self:DefaultShoot()
end

function SWEP:CheckBeforeFire()
	if (not self:CanPrimaryAttack()) then
		self:EmitSound "Weapon_Pistol.Empty"
		self:SetNextPrimaryFire(CurTime() + 0.2)
		self:Reload()
		return false
	end

	return true
end

function SWEP:DefaultShoot()
	if (not self:CheckBeforeFire()) then
		return
	end

	if (self:Clip1() <= math.max(self:GetMaxClip1() * 0.15, 3)) then
		self:EmitSound("weapons/pistol/pistol_empty.wav", self.Primary.SoundLevel, 255, 2, CHAN_USER_BASE + 1)
	end

	if (self.Primary.Sound) then
		self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel or 1)
	end

	local shot = self:ShootBullet() or 1

	if (not self:GetDeveloperMode()) then
		self:TakePrimaryAmmo(shot)
	end

	self:ViewPunch()
end

local quat_zero = Quaternion()

function SWEP:GenerateRecoilInstructions()
	if (not self.RecoilInstructions) then
		self.RecoilInstructions = {
			Angle(5, -3),
			Angle(5, -3),
			Angle(0, 8)
		}
	end

	return self.RecoilInstructions
end

function SWEP:GetCurrentViewPunch()
	local delay = self.Primary.RecoilTiming or self:GetDelay()
	local time = self:GetViewPunchTime()
	local frac = (CurTime() - time) / delay
	
	if (frac >= 1) then
		return angle_zero
	end

	local vp = self:GetViewPunch()
	local diff = Quaternion():SetEuler(-vp):Slerp(quat_zero, frac):ToEulerAngles()

	return diff
end

function SWEP:ViewPunch()
	if (self:GetDeveloperMode()) then
		return
	end
	
	local vp = self:GetViewPunchAngles()
	self:SetViewPunch(vp)
	self:SetViewPunchTime(CurTime())

	if (not CLIENT or not IsFirstTimePredicted()) then
		return
	end

	local own = self:GetOwner()
	own:SetEyeAngles(own:EyeAngles() + vp)

	self:CalcViewPunch()
end

function SWEP:GetIdleAnimation()
	return ACT_VM_IDLE
end

function SWEP:Think()
	local reloadtime = self:GetReloadEndTime()
	if (reloadtime ~= math.huge) then
		if (reloadtime > CurTime()) then
			local time = (CurTime() - self:GetReloadStartTime())

			local snd = IsFirstTimePredicted() and self.Sounds and self.Sounds.reload
			if (snd) then
				for _ = #snd, 1, -1 do
					local inf = snd[_]
					if (inf.time / self:GetReloadAnimationSpeed() <= time) then
						if (self.LastSound ~= inf.sound) then
							self:EmitSound(inf.sound)
							self.LastSound = inf.sound
						end
						break
					end
				end
			end

			return
		end

		local ammocount = self:GetReserveAmmo()
		local needed = self:GetMaxClip1() - self:Clip1()

		local added = math.min(needed, ammocount)

		self:GetOwner():SetAmmo(ammocount - added, self:GetPrimaryAmmoType())

		self:SetClip1(self:Clip1() + added)
		self:SetReloadEndTime(math.huge)
	end

	local vm = self:GetOwner():GetViewModel(self:ViewModelIndex())
	if (vm:IsSequenceFinished()) then
		vm:SendViewModelMatchingSequence(vm:SelectWeightedSequence(self:GetIdleAnimation()))
	end

	if (not self:IsToggleADS()) then
		if (not self:GetIronsights() and self:GetOwner():KeyDown(IN_ATTACK2)) then
			self:SecondaryAttack()
		elseif (self:GetIronsights() and not self:GetOwner():KeyDown(IN_ATTACK2)) then
			self:ChangeIronsights(false)
		end
	end

	if (CLIENT) then
		self:CalcAllUnpredicted()
	end
end

function SWEP:GetCurrentZoomMultiplier()
	return math.min(1, (CurTime() - self:GetFOVMultiplierTime()) / (self:GetFOVMultiplierDuration() + 0.00001))
end

function SWEP:GetCurrentZoomPercent()
	if (self:GetIronsights()) then
		return self:GetCurrentZoomMultiplier()
	else
		return 1 - self:GetCurrentZoomMultiplier()
	end
end

function SWEP:GetCurrentFOVMultiplier()
	if (not self.GetOldFOVMultiplier) then
		return self.Ironsights.Zoom
	end

	return self:GetOldFOVMultiplier() + (self:GetFOVMultiplier() - self:GetOldFOVMultiplier()) * self:GetCurrentZoomMultiplier()
end

function SWEP:ChangeFOVMultiplier(fovmult, duration)
	self:SetOldFOVMultiplier(self:GetCurrentFOVMultiplier())
	self:SetFOVMultiplier(fovmult)
	self:SetFOVMultiplierDuration(duration)
	self:SetFOVMultiplierTime(CurTime())
end

function SWEP:GetCurrentZoom()
	local mult = 1
	if (self.Ironsights) then
		local base = self.Ironsights.Zoom
		mult = (self:GetCurrentFOVMultiplier() - base) / (1 - base + 0.000001)
	end
	return mult
end

function SWEP:GetMultiplier()
	return (1 + math.max(0, 1 - self:GetConsecutiveShots() / 4))
end

function SWEP:GetViewPunchAngles()
	local instr = self:GenerateRecoilInstructions()
	local thing = math.floor(self:GetConsecutiveShots() / (instr.Interval or 10))

	local current = instr[thing % #instr + 1]

	return current / 10
end

function SWEP:GetSlowdown()
	return self:GetIronsights() and self.Ironsights and self.Ironsights.SlowDown or 1
end

function SWEP:AdjustMouseSensitivity()
	if (self:GetIronsights()) then
		return self.Ironsights.Zoom
	end
end

function SWEP:GetReloadAnimationSpeed()
	return self.ReloadSpeed
end

function SWEP:GetReloadDuration(speed)
	return self:SequenceDuration() / speed + 0.1
end

function SWEP:DoReload(act)
	local speed = self:GetReloadAnimationSpeed()

	self:SendWeaponAnim(act)
	self:SetPlaybackRate(speed)
	if (IsValid(self:GetOwner())) then
		self:GetOwner():GetViewModel():SetPlaybackRate(speed)
		self:GetOwner():DoCustomAnimEvent(PLAYERANIMEVENT_RELOAD, 0)
	end

	local endtime = CurTime() + self:GetReloadDuration(speed)

	self.LastSound = nil
	self:SetReloadStartTime(CurTime())
	self:SetReloadEndTime(endtime)
	self:SetNextPrimaryFire(endtime)
	self:SetNextSecondaryFire(endtime)
end

function SWEP:CancelReload()
	self:SetNextPrimaryFire(CurTime() + self:GetDelay())
	self:SetNextSecondaryFire(CurTime() + self:GetDelay())
	self:SetReloadEndTime(math.huge)
end

function SWEP:Holster()
	self.FirstThink = false
	self:CancelReload()
	self:SendWeaponAnim(ACT_VM_HOLSTER)
	return true
end


-- accessors for stuff so you can override easier

function SWEP:GetDamage()
	return self.Primary.Damage
end

function SWEP:GetTracers()
	return self.Bullets.Tracer or 1
end

function SWEP:GetTracerName()
	return self.Bullets.TracerName or "Tracer"
end

function SWEP:GetDamageDropoffRange()
	return self.Bullets.DamageDropoffRange
end

function SWEP:GetDamageDropoffRangeMax()
	return self.Bullets.DamageDropoffRangeMax
end

function SWEP:GetDamageMinimumPercent()
	return self.Bullets.DamageMinimumPercent
end

function SWEP:GetIronsightsTimeFrom()
	return self.Ironsights.TimeFrom
end

function SWEP:GetIronsightsTimeTo()
	return self.Ironsights.TimeTo
end

function SWEP:GetDelay()
	return self.Primary.Delay or 1
end

function SWEP:CreateModels(tab)
	if (not tab) then
		return
	end

	for k, v in pairs( tab ) do
		if (v.type == "Model" and v.model and v.model ~= "" and (not IsValid(v.modelEnt) or v.createdModel ~= v.model)) then
			v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
			if (IsValid(v.modelEnt)) then
				v.modelEnt:SetPos(self:GetPos())
				v.modelEnt:SetAngles(self:GetAngles())
				v.modelEnt:SetParent(self)
				v.modelEnt:SetNoDraw(true)
				v.createdModel = v.model
			else
				v.modelEnt = nil
			end
		elseif (v.type == "Sprite" and v.sprite and v.sprite ~= "" and (not v.spriteMaterial or v.createdSprite ~= v.sprite)) then
			local name = v.sprite.."-"

			local params = {
				["$basetexture"] = v.sprite
			}

			-- // make sure we create a unique name based on the selected options
			local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
			for i, j in pairs(tocheck) do
				if (v[j]) then
					params["$"..j] = 1
					name = name.."1"
				else
					name = name.."0"
				end
			end

			v.createdSprite = v.sprite
			v.spriteMaterial = CreateMaterial(name, "UnlitGeneric", params)
		end
	end
end
