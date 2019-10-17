
local PANEL = {}

function PANEL:Init()
	self.Text = "Label"
	self.Font = "DermaDefault"
	self.Children = {}
	self.Color = white_text
end

function PANEL:AddLine(line)
	local pnl = self:Add "DLabel"
	pnl:SetFont(self.Font)
	pnl:SetTextColor(self.Color)
	pnl:SetText(line)
	pnl:SetContentAlignment(5)
	pnl:Dock(TOP)
	pnl:SetZPos(#self.Children)
	local _, h = surface.GetTextSize(line)
	pnl:SetTall(h)
	self.Tall = self.Tall + h
	table.insert(self.Children, pnl)
end

function PANEL:PerformLayout(_w, _h)
	if (self.LastText == self.Text and self.LastWide == _w) then
		return
	end
	self.LastText = self.Text
	self.LastWide = _w
	for _, child in pairs(self.Children) do
		child:Remove()
	end

	self.Children = {}

	local cur = {}
	surface.SetFont(self.Font)
	self.Tall = 0

	for word in self.Text:gmatch("([^%s]+)%s*") do
		cur[#cur + 1] = word
		local w, h = surface.GetTextSize(table.concat(cur, " "))
		if (w > _w) then
			if (#cur == 1) then
				self:AddLine(word)
				cur = {}
			else
				cur[#cur] = nil
				self:AddLine(table.concat(cur, " "))
				local w, h = surface.GetTextSize(word)
				if (w > _w) then
					self:AddLine(word)
					cur = {}
				else
					cur = {word}
				end
			end
		end
	end

	if (#cur > 0) then
		self:AddLine(table.concat(cur, " "))
	end

	self:SetTall(self.Tall)
end

function PANEL:SetTextColor(col)
	self.Color = col
	for _, child in pairs(self.Children) do
		child:SetTextColor(col)
	end
end

function PANEL:SetFont(font)
	self.Font = font
	self:InvalidateLayout(true)
end

function PANEL:SetText(text)
	self.Text = text
	self:InvalidateLayout(true)
end

vgui.Register("ttt_centered_wrap", PANEL, "EditablePanel")