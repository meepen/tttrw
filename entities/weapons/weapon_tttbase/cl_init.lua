include "shared.lua"

function SWEP:DoDrawCrosshair(x, y)
	surface.SetDrawColor(255,0,255,255)
	surface.DrawRect(x - 5, y - 5, 10, 10)
	return true
end