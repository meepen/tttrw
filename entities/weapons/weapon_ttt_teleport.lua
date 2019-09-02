AddCSLuaFile()

SWEP.HoldType              = "normal"

SWEP.PrintName          = "Teleporter"
SWEP.Slot               = 6

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = 10

SWEP.Icon               = "vgui/ttt/icon_m16"
SWEP.IconLetter         = "w"

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind                  = WEAPON_EQUIP2
SWEP.WeaponID              = AMMO_TELEPORT

SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.ClipSize      = 16
SWEP.Primary.DefaultClip   = 16
SWEP.Primary.Delay		   = .5

SWEP.Secondary.Delay 		= 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = true

SWEP.ViewModel             = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel            = "models/weapons/w_crowbar.mdl"

SWEP.Equipment = {
	Name		   = "Teleporter",
	Desc 		   = "Store a location with right click, then travel there again with left click.",
	CanBuy	       = { traitor = true },
	Cost 	   	   = 1,
	Limit	       = 1,
}

DEFINE_BASECLASS "weapon_tttbase"

local delay_beamup = 1
local delay_beamdown = 1

local ttt_telefrags = CreateConVar("ttt_teleport_telefrags", "0")

function SWEP:SetTeleportMark(pos, ang)
	self.teleport = {pos = pos, ang = ang}
end

function SWEP:GetTeleportMark() return self.teleport end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

	if self:Clip1() <= 0 then
		return
	end

	-- Disallow initiating teleports during post, as it will occur across the
	-- restart and allow the user an advantage during prep
	if ttt.GetRoundState() == ttt.ROUNDSTATE_ENDED then return end

	if SERVER then
		self:TeleportRecall()
	else
		surface.PlaySound("buttons/combine_button7.wav")
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	if SERVER then
		self:TeleportStore()
	else
		surface.PlaySound("ui/buttonrollover.wav")
	end
end

local zap = Sound("ambient/levels/labs/electric_explosion4.wav")
local unzap = Sound("ambient/levels/labs/electric_explosion2.wav")

local function Telefrag(victim, attacker, weapon)
	if not IsValid(victim) then return end

	local dmginfo = DamageInfo()
	dmginfo:SetDamage(5000)
	dmginfo:SetDamageType(DMG_SONIC)
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(weapon)
	dmginfo:SetDamageForce(Vector(0,0,10))
	dmginfo:SetDamagePosition(attacker:GetPos())

	victim:TakeDamageInfo(dmginfo)
end


local function ShouldCollide(ent)
	local g = ent:GetCollisionGroup()
	return (g != COLLISION_GROUP_WEAPON and
			g != COLLISION_GROUP_DEBRIS and
			g != COLLISION_GROUP_DEBRIS_TRIGGER and
			g != COLLISION_GROUP_INTERACTIVE_DEBRIS)
end

	-- Teleport a player to a {pos, ang}
local function TeleportPlayer(ply, teleport)
	local oldpos = ply:GetPos()
	local pos = teleport.pos
	local ang = teleport.ang

	-- print decal on destination
	util.PaintDown(pos + Vector(0,0,25), "GlassBreak", ply)

	-- perform teleport
	ply:SetPos(pos)
	ply:Freeze(false)
	ply:SetEyeAngles(ang)

	sound.Play(zap, oldpos, 65, 100)
	sound.Play(unzap, pos, 55, 100)

	-- print decal on source now that we're gone, because else it will refuse
	-- to draw for some reason
	util.PaintDown(oldpos + Vector(0,0,25), "GlassBreak", ply)
end

	-- Checks teleport destination. Returns bool and table, if bool is true then
	-- location is blocked by world or prop. If table is non-nil it contains a list
	-- of blocking players.
local function CanTeleportToPos(ply, pos)
	-- first check if we can teleport here at all, because any solid object or
	-- brush will make us stuck and therefore kills/blocks us instead, so the
	-- trace checks for anything solid to players that isn't a player
	local tr = nil
	local tres = {start=pos, endpos=pos, mask=MASK_PLAYERSOLID, filter=player.GetAll()}
	local collide = false

	-- This thing is unnecessary if we can supply a collision group to trace
	-- functions, like we can in source and sanity suggests we should be able
	-- to do so, but I have not found a way to do so yet. Until then, re-trace
	-- while extending our filter whenever we hit something we don't want to
	-- hit (like weapons or ragdolls).
	repeat
		tr = util.TraceEntity(tres, ply)

		if tr.HitWorld then
			collide = true
		elseif IsValid(tr.Entity) then
			if ShouldCollide(tr.Entity) then
			collide = true
			else
			table.insert(tres.filter, tr.Entity)
			end
		end
	until (not tr.Hit) or collide

	if collide then
		--Telefrag(ply, ply)
		return true, nil
	else

		-- find all players in the place where we will be and telefrag them
		local blockers = ents.FindInBox(pos + Vector(-16, -16, 0),
										pos + Vector(16, 16, 64))

		local blocking_plys = {}

		for _, block in pairs(blockers) do
			if IsValid(block) then
			if block:IsPlayer() and block != ply then
				if block:Alive() then
					table.insert(blocking_plys, block)
					-- telefrag blocker
					--Telefrag(block, ply)
				end
			end
			end
		end

		return false, blocking_plys
	end

	return false, nil
end

local function DoTeleport(ply, teleport, weapon)
	if IsValid(ply) and teleport then
		local fail = false

		local block_world, block_plys = CanTeleportToPos(ply, teleport.pos)

		if block_world then
			-- if blocked by prop/world, always fail
			fail = true
		elseif block_plys and #block_plys > 0 then
			-- if blocked by player, maybe telefrag
			if ttt_telefrags:GetBool() then
			for _, p in pairs(block_plys) do
				Telefrag(p, ply, weapon)
			end
			else
			fail = true
			end
		end

		if not fail then
			TeleportPlayer(ply, teleport)
		else
			ply:Freeze(false)
			if (CLIENT) then chat.AddText(Color(255,50,50), "Teleport Failed!") end
		end
	elseif IsValid(ply) then
		-- should never happen, but at least unfreeze
		ply:Freeze(false)
		if (CLIENT) then chat.AddText(Color(255,50,50), "Teleport Failed!") end
	end
end

local function StartTeleport(ply, teleport, weapon)
	if (not IsValid(ply)) or (not teleport) then
		return end

	--teleport.ang = ply:EyeAngles()

	timer.Simple(delay_beamup, function() DoTeleport(ply, teleport, weapon) end)

	local ang = ply:GetAngles()

	local edata_up = EffectData()
	edata_up:SetOrigin(ply:GetPos())
	ang = Angle(0, ang.y, ang.r) -- deep copy
	edata_up:SetAngles(ang)
	edata_up:SetEntity(ply)
	edata_up:SetMagnitude(delay_beamup)
	edata_up:SetRadius(delay_beamdown)

	util.Effect("teleport_beamup", edata_up)

	local edata_dn = EffectData()
	edata_dn:SetOrigin(teleport.pos)
	ang = Angle(0, ang.y, ang.r) -- deep copy
	edata_dn:SetAngles(ang)
	edata_dn:SetEntity(ply)
	edata_dn:SetMagnitude(delay_beamup)
	edata_dn:SetRadius(delay_beamdown)

	util.Effect("teleport_beamdown", edata_dn)
end

function SWEP:TeleportRecall()
	local ply = self:GetOwner()
	if IsValid(ply) then
		local mark = self:GetTeleportMark()
		if mark then

			ply:Freeze(true)

			self:TakePrimaryAmmo(1)

			timer.Simple(0.2, function() StartTeleport(ply, mark, self) end)
		else
			if (CLIENT) then chat.AddText(Color(255,50,50), "No location marked yet!") end
		end
	end
end

local function CanStoreTeleportPos(ply, pos)
	local g = ply:GetGroundEntity()
	if g != game.GetWorld() or (IsValid(g) and g:GetMoveType() != MOVETYPE_NONE) then
		return false, "Couldn't Mark: You must be standing on the ground!"
	elseif ply:Crouching() then
		return false, "Couldn't Mark: You can't be crouching to mark a location!"
	end

	return true, nil
end

function SWEP:TeleportStore()
	local ply = self:GetOwner()
	if IsValid(ply) then

		local allow, msg = CanStoreTeleportPos(ply, self:GetPos())
		if not allow then
			if (CLIENT) then chat.AddText(Color(255,50,50), msg) end
			return
		end

		self:SetTeleportMark(ply:GetPos(), ply:EyeAngles())

		if (CLIENT) then chat.AddText(Color(50,50,255), "Location Stored.") end
	end
end



function SWEP:Reload()
	return false
end

function SWEP:Deploy()
	if SERVER and IsValid(self:GetOwner()) then
		self:GetOwner():DrawViewModel(false)
	end

	return true
end

function SWEP:ShootEffects() end