gameevent.Listen "player_hurt"
gameevent.Listen "entity_killed"

GM.Damages = GM.Damages or {}

local LIFETIME = 1.5

net.Receive("tttrw_damage_position", function(len, cl)
	table.insert(ttt.Damages, {
		Position = net.ReadVector(),
		Time = CurTime(),
		Damage = net.ReadFloat()
	})
end)


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
		surface.SetDrawColor(200, 20, 20, (1 - (Time - Damage.Time) / LIFETIME) * (150 + (math.Clamp(Damage.Damage / LocalPlayer():GetMaxHealth(), 0, 1) * 100)))

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

function GM:entity_killed(info)
	local pl = LocalPlayer()
	if (IsValid(pl) and pl:UserID() == info.entindex_inflictor) then
		self.Damages = {}
	end
end
