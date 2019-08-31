gameevent.Listen "player_hurt"

GM.Damages = GM.Damages or {}

local LIFETIME = 1.5

function GM:player_hurt(info)
	local inf = Player(info.userid)
	local att = Player(info.attacker)

	if (inf ~= LocalPlayer()) then
		return
	end

	table.insert(self.Damages, {
		Position = att:GetShootPos(),
		Time = CurTime(),
		Damage = inf:Health() - info.health
	})
end


function GM:TTTDrawDamagePosition()
	local Time = CurTime()

	local yaw = EyeAngles().y

	local w, h = ScrW(), ScrH()

	for i = #self.Damages, 1, -1 do
		local Damage = self.Damages[i]

		if ((Time - Damage.Time) > LIFETIME) then
			table.remove(self.Damages, i)
			continue
		end
		surface.SetDrawColor(200, 20, 20, (1 - (Time - Damage.Time) / LIFETIME) * (50 + (Damage.Damage / LocalPlayer():GetMaxHealth() * 200)))

		local ang = (Damage.Position - EyePos()):Angle().y

		local v = Vector(0, 1)
		v:Rotate(Angle(0, yaw - ang))
		local v0 = v * 1
		v0:Rotate(Angle(0, -5))
		local v1 = v * 1
		v1:Rotate(Angle(0, 5))
		v.x = -v.x

		surface.DrawPoly {
			{
				x = w / 2 - v0.x * w / 2,
				y = h / 2 - v0.y * h / 2,
			},
			{
				x = w / 2 - v1.x * w / 2,
				y = h / 2 - v1.y * h / 2,
			},
			{
				x = w / 2 - v1.x * w / 2.6,
				y = h / 2 - v1.y * h / 2.6,
			},
			{
				x = w / 2 - v0.x * w / 2.6,
				y = h / 2 - v0.y * h / 2.6,
			},
		}
	end
end