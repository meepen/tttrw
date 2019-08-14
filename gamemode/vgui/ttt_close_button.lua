local close = Material "tttrw/xbutton128.png"

local PANEL = {}

function PANEL:PerformLayout()
	self:SetText("")
end

function PANEL:DoClick()
	local parent = self:GetParent()
	if (parent) then
		parent:Remove()
	end
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetColor())
	surface.SetMaterial(close)
	surface.DrawTexturedRect(0, 0, w, h)
end

vgui.Register("ttt_close_button", PANEL, "DButton")
