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

function SKIN:PaintTextEntry( panel, w, h )
	if (panel.m_bBackground) then
		if (panel:HasFocus()) then
			surface.SetDrawColor(87, 90, 90)
		else
			surface.SetDrawColor(41, 41, 42)
		end
		surface.DrawRect(1, 0, w - 2, 1)
		surface.DrawRect(0, 1, w, h - 2)
		surface.DrawRect(1, h - 1, w - 2, 1)
	end

	panel:DrawTextEntryText(white_text, panel:GetHighlightColor(), white_text)
end

function SKIN:PaintSlider(panel, w, h)
	surface.SetDrawColor(Color(12, 13, 12))
	surface.DrawRect(0, h / 4, w, h / 2)
end

function SKIN:PaintSliderKnob(panel, w, h)
	surface.SetDrawColor(white_text)
	surface.DrawRect(0, 0, w, h)
end

derma.DefineSkin("tttrw", "TTTRW Customized Default", SKIN)

function GM:ForceDermaSkin()
	return "tttrw"
end