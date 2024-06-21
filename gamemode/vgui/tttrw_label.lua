
local PANEL = {}
AccessorFunc(PANEL, "Font", "Font")
AccessorFunc(PANEL, "TextColor", "TextColor")
AccessorFunc(PANEL, "Text", "Text")
AccessorFunc(PANEL, "surface", "RenderSystem")

local default_color = Color(255, 255, 255)

function PANEL:Init()
	self:SetCursor "beam"
	self:SetMouseInputEnabled(false)
	self:SetFade(0, -1, true)
	self.Alignment = 2
	self:SetFont "DermaDefault"
	self:SetTextColor(default_color)
	self:SetText "Label"
end

function PANEL:GetRenderSystem()
	return self.surface or (pluto and pluto.fonts.systems.default) or surface
end

function PANEL:SetClickable(clickable)
	self.Clickable = clickable

	if (clickable) then
		self:SetMouseInputEnabled(true)
		if (clickable.Cursor) then
			self:SetCursor(clickable.Cursor)
		end
	end
end

function PANEL:DoClick()
	local click = self.Clickable
	if (click and click.Run) then
		click.Run()
	end
end

function PANEL:SizeToContentsX(add)
	add = add or 0
	local surface = self:GetRenderSystem()
	surface.SetFont(self:GetFont())
	self:SetWide(surface.GetTextSize(self:GetText()) + 1 + add)
end

function PANEL:SizeToContents()
	self:SizeToContentsX(1)
	self:SizeToContentsY(1)
end

function PANEL:SizeToContentsY(add)
	add = add or 0
	local surface = self:GetRenderSystem()
	surface.SetFont(self:GetFont())
	self:SetTall(select(2, surface.GetTextSize(self:GetText())) + 1 + add)
end

function PANEL:SetContentAlignment(alignment)
	self.Alignment = alignment
end

function PANEL:Paint(w, h)
	local col = self:GetTextColor()

	if (self:GetFadeLength() ~= -1 and self:GetFadeSustain() ~= -1 and self.Creation + self:GetFadeSustain() < CurTime()) then
		col = ColorAlpha(col, col.a * (1 - math.min(1, (CurTime() - self.Creation - self:GetFadeSustain()) / self:GetFadeLength())))
	end

	local surface = self:GetRenderSystem()
	surface.SetFont(self:GetFont())
	surface.SetTextColor(col)
	local txt = self:GetText()
	local tw, th = surface.GetTextSize(txt)

	-- TODO: lookup table for alignment
	if (self.Alignment == 1) then
		surface.SetTextPos(0, h - th)
	elseif (self.Alignment == 2) then
		surface.SetTextPos(w / 2 - tw / 2, h - th)
	elseif (self.Alignment == 3) then
		surface.SetTextPos(w - tw, h - th)
	elseif (self.Alignment == 4) then
		surface.SetTextPos(0, h / 2 - th / 2 + 1)
	elseif (self.Alignment == 6) then
		surface.SetTextPos(w - tw, h / 2 - th / 2 + 0.5 )
	elseif (self.Alignment == 7) then
		surface.SetTextPos(0, 0)
	elseif (self.Alignment == 8) then
		surface.SetTextPos(w / 2 - tw / 2, 0)
	elseif (self.Alignment == 9) then
		surface.SetTextPos(w - tw, 0)
	else -- if (self.Alignment == 5) then
		surface.SetTextPos(w / 2 - tw / 2, h / 2 - th / 2 + 0.5)
	end
	surface.DrawText(txt)

	if (self.Clickable) then
		surface.SetDrawColor(col)
		surface.DrawLine(w / 2 - tw / 2, h - 1, w / 2 + tw / 2, h - 1)
	end
end

function PANEL:OnMousePressed(m)
	if (m == MOUSE_LEFT) then
		self:DoClick()
	end
end

function PANEL:SetFade(sustain, length, reset)
	self.Fade = {
		Sustain = sustain,
		Length = length
	}
	if (reset) then
		self:ResetFade()
	end
end

function PANEL:GetFadeLength()
	return self.Fade and self.Fade.Length or -1
end

function PANEL:GetFadeSustain()
	return self.Fade and self.Fade.Sustain or -1
end

function PANEL:ResetFade()
	self.Creation = CurTime()
end

vgui.Register("tttrw_label", PANEL, "EditablePanel")