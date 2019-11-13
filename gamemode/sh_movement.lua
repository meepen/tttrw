local ttt_bhop_sv, ttt_bhop_cl = CreateConVar("ttt_bhop_sv", "1", FCVAR_REPLICATED, "Allows clients to enable auto bhop")
if (CLIENT) then
	ttt_bhop_cl = CreateConVar("ttt_bhop_cl", "1", FCVAR_USERINFO + FCVAR_ARCHIVE, "Enable auto bhop if ttt_bhop_sv is enabled")
end

function GM:DoBunnyHop(ply, mv)
	-- bhop settings

	if (not ply:Alive() or ply:WaterLevel() >= 2 or ply:GetMoveType() ~= MOVETYPE_WALK) then
		return
	end

	local cl_enabled = ttt_bhop_cl and ttt_bhop_cl:GetBool()
	if (SERVER) then
		cl_enabled = ply:IsBot() or ply:GetInfoNum("ttt_bhop_cl", 0) ~= 0
	end

	if (cl_enabled and ttt_bhop_sv:GetBool() and bit.band(mv:GetButtons(), IN_JUMP) == IN_JUMP) then
		if (not ply:IsOnGround() or bit.band(mv:GetOldButtons(), IN_JUMP) == IN_JUMP) then
			mv:SetButtons(bit.band(bit.bnot(IN_JUMP), mv:GetButtons()))
		else
			mv:SetButtons(bit.bor(mv:GetButtons(), IN_JUMP))
		end
	end
end

local IN_INAIR = 0x80000000

function GM:PreventCrouchJump(ply, mv)
	if (ply:GetMoveType() ~= MOVETYPE_WALK) then
		return
	end

	local jumping = NULL == ply:GetGroundEntity() or mv:KeyDown(IN_JUMP)

	if (NULL == ply:GetGroundEntity()) then
		mv:SetButtons(bit.bor(mv:GetButtons(), IN_INAIR))
	else
		mv:SetButtons(bit.band(bit.bnot(IN_INAIR), mv:GetButtons()))
	end

	local offset = ply:GetViewOffset()
	local m_flDuckTime = math.sqrt(ply:GetCurrentViewOffset():DistToSqr(offset) / ply:GetViewOffsetDucked():DistToSqr(offset))
	if (not ply:Crouching() and m_flDuckTime >= 0.5 and jumping) then
		local velocity = mv:GetVelocity()

		local extravel = vector_origin
		local side = mv:GetSideSpeed()
		local ang = mv:GetAngles()
		ang.p = 0

		if (side ~= 0) then
			extravel = extravel + ang:Right() * (side / math.abs(side)) * 5
		end
		local forward = mv:GetForwardSpeed()
		if (forward ~= 0) then
			extravel = extravel + ang:Forward() * (forward / math.abs(forward)) * 5
		end

		velocity = (velocity + extravel) * engine.TickInterval() * 2

		local obbmins, obbmaxs = ply:GetHull()
		local tr = util.TraceHull {
			start = mv:GetOrigin(),
			endpos = mv:GetOrigin() + velocity,
			mins = obbmins,
			maxs = obbmaxs,
			filter = ply,
			mask = MASK_PLAYERSOLID,
			collisiongroup = ply:GetCollisionGroup(),
		}

		if (tr.Hit) then
			local mins, maxs = ply:GetHullDuck()
			local extravel = Vector()
			local origin = mv:GetOrigin() + Vector(0, 0, obbmaxs.z - maxs.z)
			tr = util.TraceHull {
				start = origin,
				endpos = origin + velocity,
				mins = mins,
				maxs = maxs,
				filter = ply,
				mask = MASK_PLAYERSOLID,
				collisiongroup = ply:GetCollisionGroup(),
			}

			if (not tr.Hit) then
				return
			end

			local v = tr.HitNormal
			v:Rotate(Angle(0,90))
			velocity  = velocity:GetNormalized():Dot(v) * v

			tr = util.TraceHull {
				start = origin,
				endpos = origin + velocity,
				mins = mins,
				maxs = maxs,
				filter = ply,
				mask = MASK_PLAYERSOLID,
				collisiongroup = ply:GetCollisionGroup(),
			}

			if (not tr.Hit) then
				return
			end

			mv:SetButtons(bit.band(bit.bnot(IN_DUCK), mv:GetButtons()))
		end
		mv:SetButtons(bit.band(bit.bnot(IN_DUCK), mv:GetButtons()))
	elseif (not mv:KeyWasDown(IN_INAIR) and mv:KeyDown(IN_DUCK) and mv:KeyDown(IN_JUMP) and m_flDuckTime <= 0.5) then -- on ground, jumping
		mv:SetButtons(bit.band(bit.bnot(IN_DUCK), mv:GetButtons()))
		if (m_flDuckTime ~= 0) then
			mv:SetButtons(bit.band(bit.bnot(IN_JUMP), mv:GetButtons()))
		end
		return
	end
end

function GM:Move(ply, mv)
	local data = player_manager.RunClass(ply, "GetSpeedData")

	mv:SetMaxSpeed(mv:GetMaxSpeed() * data.Multiplier * data.FinalMultiplier)
	mv:SetMaxClientSpeed(mv:GetMaxClientSpeed() * data.Multiplier * data.FinalMultiplier)

	self:DoBunnyHop(ply, mv)
	self:PreventCrouchJump(ply, mv)
end

local fallsounds = {
	Sound("player/damage1.wav"),
	Sound("player/damage2.wav"),
	Sound("player/damage3.wav")
};

function GM:OnPlayerHitGround(ply, in_water, on_floater, speed)
	if (CLIENT or in_water or speed < 450 or not IsValid(ply)) then
		return
	end

	-- Everything over a threshold hurts you, rising exponentially with speed
	local damage = math.pow(0.05 * (speed - 420), 1.75)

	-- I don't know exactly when on_floater is true, but it's probably when
	-- landing on something that is in water.
	if on_floater then damage = damage / 2 end

	if math.floor(damage) > 0 then
		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_FALL)
		dmg:SetAttacker(game.GetWorld())
		dmg:SetInflictor(game.GetWorld())
		dmg:SetDamageForce(Vector(0,0,1))
		dmg:SetDamage(damage)

		ply:TakeDamageInfo(dmg)

		-- play CS:S fall sound if we got somewhat significant damage
		if damage > 5 then
			sound.Play(table.Random(fallsounds), ply:GetShootPos(), 55 + math.Clamp(damage, 0, 50), 100)
		end
	end
end

function GM:GetFallDamage(ply, speed)
	return 0
end