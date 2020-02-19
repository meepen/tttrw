AddCSLuaFile()

local function rand()
    return math.random() * 2 - 1
end

local function RandVector(spread)
    for i = 1, 1000 do
        local v = Vector(rand(), rand(), rand())
        if (v:LengthSqr() < 1) then
            return v * spread
        end
    end
    return vector_origin
end

EFFECT.Particles = {
	Model("particle/particle_smokegrenade"),
	Model("particle/particle_noisesphere")
}


function EFFECT:Init(data)
	local dist = data:GetRadius() * 39.37 / 10

    local center = data:GetStart()

	local em = ParticleEmitter(center, false)
	local ent = data:GetEntity()
	local color = data:GetColor()

	local r = data:GetRadius()
	for i = 1, data:GetMagnitude() * 10 do
		local prpos = RandVector(dist / 2)
		local p = em:Add(table.Random(self.Particles), center + prpos)
		if (p) then
			local col
			if (color == 1) then
				col = ColorRand()
			end

			if (not col) then
				local gray = math.random(75, 200)
				col = Color(gray, gray, gray)
			end
			p:SetColor(col.r, col.g, col.b)
			p:SetStartAlpha(255)
			p:SetEndAlpha(0)
			p:SetLifeTime(0)
			
			p:SetDieTime(12 + math.random() * 5)

			p:SetStartSize(math.random() * dist * 0.4 + dist * 0.1)
			p:SetEndSize(math.random() * dist * 0.2 + dist * 0.1)
			p:SetRoll(rand() * 180)
			p:SetRollDelta(rand() * 0.1)
			p:SetAirResistance(600)

			p:SetLighting(false)
            p:SetVelocity(vector_origin)
		end
	end

	em:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end
