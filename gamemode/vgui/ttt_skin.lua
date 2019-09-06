local SKIN = {}

local c = Color(204, 203, 203)
local green = Color(32, 175, 126)

local pad = 4
function SKIN:PaintCheckBox(panel, w, h)
	surface.SetDrawColor(c)
	surface.DrawRect(1, 0, w - 2, pad)
	surface.DrawRect(0, 1, pad, h - 2)
	surface.DrawRect(w - pad, 1, pad, h - 2)
	surface.DrawRect(1, h - pad, w - 2, pad)
	
	
	if (panel:GetChecked()) then
		surface.SetDrawColor(green)
		surface.DrawRect(pad, pad, w - pad * 2, h - pad * 2)
	end
end

derma.DefineSkin("tttrw", "TTTRW Customized Default", SKIN)

function GM:ForceDermaSkin()
	return "tttrw"
end