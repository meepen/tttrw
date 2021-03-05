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
	surface.SetDrawColor(0x21, 0x22, 0xa, 128)
	ttt.DrawCurvedRect(2, 6, w - 4, h - 12, 2)
end

function SKIN:PaintSliderKnob(panel, w, h)
	surface.SetDrawColor(white_text)
	ttt.DrawCurvedRect(0, 0, w, h, 6)
end

function SKIN:PaintCollapsibleCategory(panel, w, h)

	surface.SetDrawColor(dark)
	surface.DrawRect(0, 0, w, select(2, panel.Header:GetTextSize()) + 2)

end

function SKIN:PaintCategoryList( panel, w, h )

end

derma.DefineSkin("tttrw", "TTTRW Customized Default", SKIN)

function GM:ForceDermaSkin()
	return "tttrw"
end

local PANEL = {}

function PANEL:Init()
	self.Offset = 0
	self.Scroll = 0
	self.CanvasSize = 1
	self.BarSize = 1

	self.Inner = self:Add "EditablePanel"
	function self.Inner:Paint(w, h)
		derma.SkinHook( "Paint", "Slider", self, w, h )
	end
	self.Inner:Dock(FILL)
	self.Inner:DockMargin(1, 0, 1, 0)
	self.Inner.Grip = function(s, ...)
		self:Grip(...)
	end

	self.btnGrip = self:Add "EditablePanel"

	function self.btnGrip:OnMousePressed()
		self:GetParent():Grip(1)
	end

	function self.btnGrip:Paint(w, h)
		derma.SkinHook("Paint", "SliderKnob", self, w, h)
	end

	self:SetSize(12, 20)
end

function PANEL:SetEnabled( b )
	if (not b) then
		self.Offset = 0
		self:SetScroll(0)
		self.HasChanged = true
	end

	self:SetMouseInputEnabled(b)
	self:SetVisible(b)

	-- We're probably changing the width of something in our parent
	-- by appearing or hiding, so tell them to re-do their layout.
	if (self.Enabled ~= b) then
		self:GetParent():InvalidateLayout()

		if ( self:GetParent().OnScrollbarAppear ) then
			self:GetParent():OnScrollbarAppear()
		end
	end

	self.Enabled = b
end

function PANEL:Value()
	return self.Pos
end

function PANEL:BarScale()
	return 1
end

function PANEL:SetUp( _barsize_, _canvassize_ )
	self.BarSize = _barsize_
	self.CanvasSize = math.max(_canvassize_ - _barsize_, 1)

	self:SetEnabled(_canvassize_ > _barsize_)

	self:InvalidateLayout()
end

function PANEL:OnMouseWheeled(dlta)
	if (!self:IsVisible()) then return false end

	-- We return true if the scrollbar changed.
	-- If it didn't, we feed the mousehweeling to the parent panel
	return self:AddScroll(dlta * -2)
end

function PANEL:AddScroll(dlta)
	local OldScroll = self:GetScroll()

	dlta = dlta * 25
	self:SetScroll( self:GetScroll() + dlta )

	return OldScroll != self:GetScroll()
end

function PANEL:SetScroll(scrll)
	if (not self.Enabled) then
		self.Scroll = 0
		return
	end

	self.Scroll = math.Clamp( scrll, 0, self.CanvasSize )

	self:InvalidateLayout()

	-- If our parent has a OnVScroll function use that, if
	-- not then invalidate layout (which can be pretty slow)

	local func = self:GetParent().OnVScroll
	if (func) then
		func(self:GetParent(), self:GetOffset())
	else
		self:GetParent():InvalidateLayout()
	end
end

function PANEL:AnimateTo(scrll, length, delay, ease)
	local anim = self:NewAnimation( length, delay, ease )
	anim.StartPos = self.Scroll
	anim.TargetPos = scrll
	anim.Think = function( anim, pnl, fraction )
		pnl:SetScroll(Lerp(fraction, anim.StartPos, anim.TargetPos))
	end
end

function PANEL:GetScroll()
	if (not self.Enabled) then
		self.Scroll = 0
	end

	return self.Scroll
end

function PANEL:GetOffset()
	if (not self.Enabled) then
		return 0
	end
	return -self.Scroll
end

function PANEL:Think()
end

function PANEL:OnMousePressed()
	local x, y = self:CursorPos()

	local PageSize = self.BarSize

	if ( y > self.btnGrip.y ) then
		self:SetScroll(self:GetScroll() + PageSize)
	else
		self:SetScroll(self:GetScroll() - PageSize)
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = false
	self.DraggingCanvas = nil
	self:MouseCapture(false)

	self.btnGrip.Depressed = false
end

function PANEL:OnCursorMoved( x, y )
	if (not self.Enabled or not self.Dragging) then
		return
	end

	local x, y = self:ScreenToLocal(0, gui.MouseY())

	y = y - self.HoldPos

	local TrackSize = self:GetTall()

	y = y / TrackSize

	self:SetScroll(y * self.CanvasSize)
end

function PANEL:Grip()
	if (not self.Enabled or self.BarSize == 0) then
		return
	end

	self:MouseCapture(true)
	self.Dragging = true

	local x, y = self.btnGrip:ScreenToLocal(0, gui.MouseY())
	self.HoldPos = y

	self.btnGrip.Depressed = true
end

function PANEL:PerformLayout(Wide, h)
	local pct = self:GetScroll() / (self.CanvasSize)
	self.btnGrip:SetPos(0, pct * (h - self.btnGrip:GetTall()))
	self.btnGrip:SetSize(Wide, Wide)
end

derma.DefineControl("DVScrollBar", "A Scrollbar", PANEL, "EditablePanel")