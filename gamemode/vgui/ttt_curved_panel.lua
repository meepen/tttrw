surface.CreateFont("tttrw_base_tab", {
	font = "Lato",
	extended = true,
	weight = 100,
	size = 20
})

surface.CreateFont("tttrw_tab_selector", {
	font = "Roboto",
	extended = true,
	weight = 100,
	size = 18
})

local PANEL = {}
ttt.ColorMaterials = ttt.ColorMaterials or {}

AccessorFunc(PANEL, "Curve", "Curve", FORCE_NUMBER)
AccessorFunc(PANEL, "Color", "Color")

for _, name in pairs {"CurveTopRight", "CurveTopLeft", "CurveBottomLeft", "CurveBottomRight"} do
	PANEL["Set" .. name] = function(self, v)
		self[name] = v
		if (IsValid(self.Mesh)) then
			self:RebuildMesh()
		end
	end

	PANEL[name] = true

	PANEL["GetNo" .. name] = function(self)
		return not self[name]
	end
end

function PANEL:SetColor(col)
	if (col ~= self.Color) then
		self.Color = col
		self:RebuildMesh()
	end
end

function PANEL:SetCurve(curve)
	self.Curve = curve
	self:RebuildMesh()
end

function PANEL:RebuildMesh(w, h)
	if (not w) then
		w, h = self:GetSize()
	end

	if (IsValid(self.Mesh)) then
		self.Mesh:Destroy()
		self.Mesh = nil
	end

	local x, y = self:LocalToScreen(0, 0)

	self.Mesh = hud.BuildCurvedMesh(self:GetCurve() or 0, x, y, w, h, self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight(), self:GetColor() or color_white)
end

local memoize = {}

hook.Add("PostRenderVGUI", "ttt_curved_panel", function()
	memoize = {}
end)

local function GetRenderBounds(self)
	local m = memoize[self]
	if (m ~= nil) then
		return m[1], m[2], m[3], m[4]
	end

	local x0, y0 = self:LocalToScreen(0, 0)
	local x1, y1 = self:LocalToScreen(self:GetSize())

	local parent = self:GetParent()

	if (IsValid(parent)) then
		local px0, py0, px1, py1 = GetRenderBounds(parent)
		x0 = math.max(x0, px0)
		y0 = math.max(y0, py0)
		x1 = math.min(x1, px1)
		y1 = math.min(y1, py1)
	end

	memoize[self] = {x0, y0, x1, y1}

	return x0, y0, x1, y1
end

PANEL.GetRenderBounds = GetRenderBounds

function PANEL:SetScissor(b)
	self.DontScissor = not b
end

function PANEL:GetScissor()
	return not self.DontScissor
end

function PANEL:Scissor()
	if (not self:GetScissor()) then
		return
	end
	local x0, y0, x1, y1 = self:GetRenderBounds()
	render.SetScissorRect(x0, y0, x1, y1, true)
end

function PANEL:MeshRemove()
	if (IsValid(self.Mesh)) then
		self.Mesh:Destroy()
	end

	if (self.OldRemove) then
		self:OldRemove()
	end
end

function PANEL:Paint(w, h)
	self.OldRemove = self.OldRemove or self.OnRemove or function() end
	self.OnRemove = self.MeshRemove

	local x, y = self:LocalToScreen(0, 0)
	if (self._OLDW ~= w or self._OLDH ~= h or self._OLDX ~= x or self._OLDY ~= y) then
		self:RebuildMesh(w, h)
		self._OLDW = w
		self._OLDH = h
		self._OLDX = x
		self._OLDY = y
	end

	self:Scissor()
	render.SetColorMaterial()
	if (true) then
		hud.StartStenciledMesh(self.Mesh, 0, 0)
		surface.SetDrawColor(self.Color or color_white)
		surface.DrawRect(0, 0, self:GetSize())
		hud.EndStenciledMesh()
	else
		self.Mesh:Draw()
	end
	render.SetScissorRect(0, 0, 0, 0, false)
end

vgui.Register("ttt_curved_panel", PANEL, "EditablePanel")
PANEL = table.Copy(PANEL)
AccessorFunc( PANEL, "m_bDisabled",		"Disabled",			FORCE_BOOL )

function PANEL:Init()
	self:SetCursor "hand"

	self.Label = self:Add "DLabel"
	self.Label:SetContentAlignment(5)
	self.Label:Dock(FILL)
end

function PANEL:SetTextColor(c)
	self.Label:SetTextColor(c)
end

function PANEL:SetText(c)
	self.Label:SetText(c)
end

function PANEL:GetTexT()
	return self.Label:GetText()
end

function PANEL:SetFont(f)
	self.Label:SetFont(f)
end

function PANEL:GetFont(f)
	return self.Label:GetFont()
end

function PANEL:OnMousePressed( mousecode )

	if ( self:GetDisabled() ) then return end

	if ( mousecode == MOUSE_LEFT && !dragndrop.IsDragging() && self.m_bDoubleClicking ) then

		if ( self.LastClickTime && SysTime() - self.LastClickTime < 0.2 ) then

			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return

		end

		self.LastClickTime = SysTime()

	end

	-- If we're selectable and have shift held down then go up
	-- the parent until we find a selection canvas and start box selection
	if ( self:IsSelectable() && mousecode == MOUSE_LEFT && input.IsShiftDown() ) then

		return self:StartBoxSelection()

	end

	self:MouseCapture( true )
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout(true)

	--
	-- Tell DragNDrop that we're down, and might start getting dragged!
	--
	self:DragMousePress( mousecode )
end

function PANEL:OnReleased()
end

function PANEL:OnDepressed()
end

function PANEL:OnToggled(bool)
end

function PANEL:DoClick()
end

function PANEL:DoRightClick()
end

function PANEL:DoMiddleClick()
end

function PANEL:DoClickInternal()
end

function PANEL:DoDoubleClick()
end

function PANEL:DoDoubleClickInternal()
end

function PANEL:OnMouseReleased( mousecode )

	self:MouseCapture( false )

	if ( self:GetDisabled() ) then return end
	if ( !self.Depressed && dragndrop.m_DraggingMain != self ) then return end

	if ( self.Depressed ) then
		self.Depressed = nil
		self:OnReleased()
		self:InvalidateLayout( true )
	end

	--
	-- If we were being dragged then don't do the default behaviour!
	--
	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end
	
	if ( self:IsSelectable() && mousecode == MOUSE_LEFT ) then

		local canvas = self:GetSelectionCanvas()
		if ( canvas ) then
			canvas:UnselectAll()
		end

	end

	if ( !self.Hovered ) then return end

	--
	-- For the purposes of these callbacks we want to
	-- keep depressed true. This helps us out in controls
	-- like the checkbox in the properties dialog. Because
	-- the properties dialog will only manually change the value
	-- if IsEditing() is true - and the only way to work out if
	-- a label/button based control is editing is when it's depressed.
	--
	self.Depressed = true

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClickInternal()
		self:DoClick()
	end

	if ( mousecode == MOUSE_MIDDLE ) then
		self:DoMiddleClick()
	end

	self.Depressed = nil

end

vgui.Register("ttt_curved_button", table.Copy(PANEL), "EditablePanel")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:RebuildMesh(w, h)
	if (IsValid(self.Mesh)) then
		self.Mesh:Destroy()
		self.Mesh = nil
	end

	local x, y = self:LocalToScreen(0, 0)

	self.Mesh = hud.BuildCurvedMeshOutline(self:GetCurve() or 0, x, y, self:GetWide(), self:GetTall(), self:GetNoCurveTopLeft(), self:GetNoCurveTopRight(), self:GetNoCurveBottomLeft(), self:GetNoCurveBottomRight(), self:GetColor())
end

function PANEL:DrawInner()
end

function PANEL:Paint(w, h)
	BaseClass.Paint(self, w, h)
	self:DrawInner(w, h)
end

vgui.Register("ttt_curved_panel_outline", PANEL, "ttt_curved_panel")
vgui.Register("ttt_curved_outline_button", table.Copy(PANEL), "ttt_curved_button")

local function ShadowColor(col)
	return ColorAlpha(col, 100)
end

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	self:DockPadding(1, 1, 1, 1)
end
function PANEL:SetColor(col)
	BaseClass.SetColor(self, ShadowColor(col))
end
vgui.Register("ttt_curved_panel_shadow", PANEL, "ttt_curved_panel_outline")
vgui.Register("ttt_curved_panel_shadow_button", table.Copy(PANEL), "ttt_curved_outline_button")

local function hexlit(a)
	return tonumber(a, 16)
end

local function HexColor(h)
	if (h[1] == "#") then
		h = h:sub(2)
	end

	local a, r, g, b = 255

	if (h:len() <= 4) then
		h = h:gsub(".", "%1%1")
	end

	local col = {}

	
	for num in h:gmatch "(..)" do
		col[#col + 1] = tonumber(num, 16)
	end

	return Color(unpack(col))
end

outline = HexColor "#0e1c20ff"
inactive_tab = HexColor "#202629ff"
main_color = HexColor "#0b121370"
solid_color = Color(42, 50, 54)
dark = Color(32, 38, 41)

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel_shadow"
function PANEL:Init()
	BaseClass.Init(self)

	self.Tabs = {}

	self.Inner = self:Add "ttt_curved_panel_outline"
	self.Inner:Dock(FILL)

	self.MainSolid = self.Inner:Add "ttt_curved_panel"
	self.MainSolid:Dock(FILL)

	self.Main = self.MainSolid:Add "ttt_curved_panel_shadow"
	self.Main:Dock(FILL)

	self:SetCurve(4)
	self.Inner:SetCurve(4)
	self.Main:SetCurve(2)
	self.MainSolid:SetCurve(2)

	self.Inner:DockPadding(2, 2, 2, 2)
	self.Main:DockPadding(8, 8, 8, 10)

	self.TabContainer = self.Main:Add "EditablePanel"
	self.TabContainer:Dock(FILL)

	self.Main.Close = self.Main:Add "ttt_close_button"
	self.Main.Close:SetColor(Color(27, 177, 126))
	self.Main.Close:SetSize(32, 32)
	
	self.Close = self.Main.Close
	self.Close.Truth = self

	function self.Close:DoClick()
		self.Truth:Remove()
	end

	function self.Main:PerformLayout(w, h)
		self.Close:SetPos(self:GetWide() - self.Close:GetWide() - 10, 8)
	end

	self.TopBar = self.TabContainer:Add "EditablePanel"
	self.TopBar:Dock(TOP)
	self.TopBar:SetTall(44)

	self.TopBar:SetZPos(2)

	self.Unused = self.TopBar:Add "EditablePanel"
	self.Unused:Dock(RIGHT)
	self.Unused:SetWide(44)

	self.TabSelector = self.TopBar:Add "tttrw_tab_selector"
	self.TabSelector.Main = self
	self.TabSelector:Dock(RIGHT)
	self.TabSelector:SetWide(24)

	self.Unused2 = self.TopBar:Add "EditablePanel"
	self.Unused2:Dock(RIGHT)
	self.Unused2:SetWide(10)

	self.TabList = self.TopBar:Add "tttrw_base_tabs"
	self.TabList:Dock(FILL)

	self.TabContentOutlineShadow = self.TabContainer:Add "ttt_curved_panel_shadow"
	self.TabContentOutline = self.TabContentOutlineShadow:Add "ttt_curved_panel_outline"
	self.TabContainer.Content = self.TabContentOutlineShadow
	self.TabContainer.TopBar = self.TopBar

	function self.TabContainer:PerformLayout(w, h)
		self.Content:SetSize(w, h - self.TopBar:GetTall() + 5)
		self.Content:SetPos(0, self.TopBar:GetTall() - 5)
	end

	self.TabContentOutline:Dock(FILL)

	self.TabContentBackdrop = self.TabContentOutline:Add "ttt_curved_panel"
	self.TabContentBackdrop:SetColor(solid_color)
	self.TabContentBackdrop:Dock(FILL)

	self.TabContentBackdropShadow = self.TabContentBackdrop:Add "ttt_curved_panel_shadow"
	self.TabContentBackdropShadow:Dock(FILL)

	self.TabContentOutlineShadow:SetCurve(4)
	self.TabContentOutline:SetCurve(4)
	self.TabContentBackdrop:SetCurve(2)
	self.TabContentBackdropShadow:SetCurve(1)
	self.TabContentOutlineShadow:SetCurveTopLeft(false)
	self.TabContentOutline:SetCurveTopLeft(false)
	self.TabContentBackdrop:SetCurveTopLeft(false)
	self.TabContentBackdropShadow:SetCurveTopLeft(false)
	self.TabContentOutline:DockPadding(2, 2, 2, 2)

	self.TabContentBackdropShadow:DockPadding(8, 10, 8, 10)

	self.Contents = self.TabContentBackdropShadow:Add "DScrollPanel"
	self.Contents:Dock(FILL)

	self.TabContentBackdropShadow:SetColor(outline)
	self.TabContentOutlineShadow:SetColor(outline)
	self.TabContentOutline:SetColor(outline)
	self:SetColor(outline)
	self.Inner:SetColor(outline)
	self.MainSolid:SetColor(main_color)
	self.Main:SetColor(outline)
end

function PANEL:AddTab(name, pnl)
	pnl.MainPanel = self
	self.Tabs[name] = pnl
	pnl:SetParent(self)
	pnl:SetVisible(false)
	if (table.Count(self.Tabs) == 1) then
		self:Select(name)
	end

	local selector = self.TabList:AddTab(name)

	local onselect = selector.OnSelect

	function selector.OnSelect(s)
		if (onselect) then
			onselect(s)
		end

		self:Select(name)
	end
end

function PANEL:Select(name)
	if (self.LastSelect ~= name) then
		if (self.LastSelect) then
			local p = self.Tabs[self.LastSelect]
			p:SetVisible(false)
			p:SetParent(self)
		end
		local p = self.Tabs[name]
		p:SetVisible(true)
		p:SetParent(p.NoScroll and self.TabContentBackdropShadow or self.Contents:GetCanvas())
		p:InvalidateLayout(true)
	end
	self.LastSelect = name
end

function PANEL:GetTabs()
	return self.Tabs
end

vgui.Register("tttrw_base", PANEL, "ttt_curved_panel_shadow")


local PANEL = {}

function PANEL:Init()
	self.Tabs = {}
	self.CurPos = 0
end

function PANEL:SetTab(name)
	self:Select(self.Tabs[name])
end

local function PerformLayoutHack(self, w, h)
	if (self.OldPerformLayout) then
		self:OldPerformLayout(w, h)
	end

	if (IsValid(self.Before)) then
		self.Position = self.Before.Position + self.Before:GetWide() + 4
	else
		self.Position = 0
	end

	self:GetParent():Recalculate(self)
end

function PANEL:Recalculate(tab)
	tab:SetPos(tab.Position - self.CurPos, 0)
	if (IsValid(tab.Next)) then
		tab.Next.Position = tab.Position + tab:GetWide() + 4
		return self:Recalculate(tab.Next)
	end
end

function PANEL:Select(tab)
	if (self.Current == tab) then
		return
	end

	if (IsValid(self.Current)) then
		self.Current.Selected = false
		self.Current:Unselect()
	end

	self.Current = tab
	if (tab.Position < self.CurPos) then
		self.CurPos = tab.Position
		self:Recalculate(tab)
	end

	if (tab.Position + tab:GetWide() > self.CurPos + self:GetWide()) then
		self.CurPos = self.CurPos + tab.Position + tab:GetWide() - (self.CurPos + self:GetWide())
		if (self.CurPos > tab.Position) then
			self.CurPos = tab.Position
		end
		self:Recalculate(self.Next)
	end

	self:DoSelect(tab)
	tab.Selected = true
	if (tab.OnSelect) then
		tab:OnSelect()
	end
end

function PANEL:DoSelect(tab)
end

function PANEL:AddTab(name, class)
	local pnl = self:Add(class or "tttrw_base_tab")
	pnl:SetName(name)
	pnl:SetZPos(table.Count(self.Tabs))
	pnl:SetWide(100)
	pnl:SetText(name)

	function pnl.DoClick(s)
		self:Select(s)
	end

	self.Tabs[name] = pnl

	if (IsValid(self.Last)) then
		self.Last.Next = pnl
	end

	pnl.Before = self.Last

	if (not IsValid(self.Next)) then
		self.Next = pnl
	end

	self.Last = pnl

	self.Last.OldPerformLayout = self.Last.PerformLayout
	self.Last.PerformLayout = PerformLayoutHack

	if (IsValid(pnl.Before)) then
		pnl.Position = pnl.Before.Position + pnl.Before:GetWide() + 4
	else
		pnl.Position = 0
	end

	if (pnl == self.Next) then
		self:Select(pnl)
	end

	return pnl
end

function PANEL:PerformLayout(w, h)
	for _, tab in pairs(self.Tabs) do
		tab:SetTall(h)
	end

	if (IsValid(self.Current)) then
		self:Select(self.Current)
	end
end

function PANEL:OnMouseWheeled(delta)
	local totalwide = self.Last.Position + self.Last:GetWide() - self:GetWide()
	if (totalwide < 0) then
		return
	end

	self.CurPos = math.Clamp(self.CurPos - delta * 30, 0, totalwide)

	self:Recalculate(self.Next)
end

vgui.Register("tttrw_base_tabs", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Outline = self:Add "ttt_curved_panel_outline"
	self.Outline:Dock(FILL)

	self.Inner = self.Outline:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)

	self.InnerShadow = self.Inner:Add "ttt_curved_panel_shadow"
	self.InnerShadow:Dock(FILL)

	self:DockPadding(1, 1, 1, 1)
	self.Outline:DockPadding(2, 2, 2, 0)

	self:SetColor(outline)
	self.Outline:SetColor(outline)
	self.InnerShadow:SetColor(outline)

	self.Inner:SetColor(inactive_tab)

	self:SetCurve(4)
	self.Outline:SetCurve(4)
	self.Inner:SetCurve(2)
	self.InnerShadow:SetCurve(1)

	self:SetCurveBottomRight(false)
	self.Outline:SetCurveBottomRight(false)
	self.Inner:SetCurveBottomRight(false)
	self.InnerShadow:SetCurveBottomRight(false)

	self:SetCurveBottomLeft(false)
	self.Outline:SetCurveBottomLeft(false)
	self.Inner:SetCurveBottomLeft(false)
	self.InnerShadow:SetCurveBottomLeft(false)

	self.InnerShadow.GetRenderBounds = self.GetRenderBounds
	self.Outline.GetRenderBounds = self.GetRenderBounds
	self.Outline.Extra = 1

	self.Label = self:Add "DLabel"
	self.Label:Dock(FILL)
	self.Label:SetContentAlignment(5)
	self.Label:SetTextColor(white_text)
	self.Label:SetFont "tttrw_base_tab"

	self.Label:SetMouseInputEnabled(false)
	self.Outline:SetMouseInputEnabled(false)
end

function PANEL:GetRenderBounds()
	local x0, y0, x1, y1 = self.BaseClass.GetRenderBounds(self)
	return x0, y0, x1, y1 - (self.Active and self:GetCurve() - (self.Extra or 0) or 0)
end

function PANEL:SetText(t)
	self.Label:SetText(t)
	surface.SetFont(self.Label:GetFont())
	local w = surface.GetTextSize(t)
	
	self:SetWide(math.max(100, w + 75))
end

function PANEL:Activate(x)
	self.Active = x
	self.InnerShadow.Active = x
	self.Outline.Active = x
	self.Inner:SetColor(x and solid_color or inactive_tab)
end

vgui.Register("tttrw_base_tab_real", PANEL, "ttt_curved_panel_shadow_button")

local PANEL = {}
function PANEL:Init()
	self.Inner = self:Add "tttrw_base_tab_real"
	self.Inner:Dock(BOTTOM)
	self.Inner:SetZPos(1)
	self.Pad = self:Add "EditablePanel"
	self.Pad:Dock(BOTTOM)
	self.Pad:SetZPos(0)

	function self.Inner:DoClick()
		self:GetParent():DoClick()
	end

	self:Unselect()
end

function PANEL:SetText(t)
	self.Inner:SetText(t)
	self:SetWide(self.Inner:GetWide())
end

function PANEL:PerformLayout(w, h)
	if (self.Selected) then
		self.Inner:SetTall(h)
	else
		self.Inner:SetTall(h - 10)
	end
end

function PANEL:OnSelect()
	self.Pad:SetTall(0)
	self.Inner:Activate(true)
end

function PANEL:Unselect()
	self.Pad:SetTall(3)
	self.Inner:Activate(false)
end

function PANEL:DoClick()
end

vgui.Register("tttrw_base_tab", PANEL, "EditablePanel")

local PANEL = {}
function PANEL:Init()
	self.Inner = self:Add "tttrw_base_tab_real"
	self.Inner:Dock(BOTTOM)
	self.Inner:SetZPos(1)
	self.Pad = self:Add "EditablePanel"
	self.Pad:Dock(BOTTOM)
	self.Pad:SetZPos(0)

	function self.Inner.DoClick()
		self:Expand()
	end

	self:OnSelect()
	self:SetText "v"
end

function PANEL:Expand()
	if (IsValid(self.Expanse)) then
		self.Expanse:Remove()
		return
	end
	self.Expanse = vgui.Create "tttrw_dropdown"
	self.Expanse:SetPos(self:LocalToScreen(0, self:GetTall()))
	self.Expanse:MakePopup()
	local now = self.Main.TabList.Next

	while (IsValid(now)) do
		local p = now
		self.Expanse:AddButton(now:GetName(), function()
			p:DoClick()
		end)
		now = now.Next
	end
end

function PANEL:OnRemove()
	if (IsValid(self.Expanse)) then
		self.Expanse:Remove()
	end
end

function PANEL:SetText(t)
	self.Inner:SetText(t)
	self:SetWide(self.Inner:GetWide())
end

function PANEL:PerformLayout(w, h)
	if (self.Selected) then
		self.Inner:SetTall(h)
	else
		self.Inner:SetTall(h - 10)
	end
end

function PANEL:OnSelect()
	self.Selected = true
	self.Pad:SetTall(0)
	self.Inner:Activate(true)
end

function PANEL:DoClick()
end

vgui.Register("tttrw_tab_selector", PANEL, "EditablePanel")


local PANEL = {}

function PANEL:Init()
	self:SetSkin "tttrw"

	self.Inner = self:Add "ttt_curved_panel_outline"
	self.Inner:Dock(FILL)
	self.InnerShadow = self:Add "ttt_curved_panel_shadow"
	self.InnerShadow:Dock(FILL)

	self.Fill = self.InnerShadow:Add "ttt_curved_panel"
	self.Fill:Dock(FILL)

	self.Fill:DockPadding(6, 6, 6, 6)

	self.Scroller = self.Fill:Add "DScrollPanel"
	self.Scroller:Dock(FILL)

	self:SetSize(200, 10)

	self.Inner:SetCurve(4)
	self:SetCurve(4)
	self.Inner:DockPadding(2, 2, 2, 2)
	self.Inner:SetCurve(2)
	self.Inner:SetColor(outline)
	self:SetColor(outline)
	self.InnerShadow:SetCurve(4)
	self.InnerShadow:SetColor(outline)

	self.Fill:SetColor(main_color)
	self.Fill:SetCurve(2)

	self.ButtonCount = 0
end

function PANEL:AddButton(text, doclick)
	local btn = self.Scroller:Add "ttt_curved_panel_shadow_button"
	btn.Inner = btn:Add "ttt_curved_panel_outline"
	btn.Inner:SetMouseInputEnabled(false)
	btn.Inner:Dock(FILL)

	btn.InnerShadow = btn.Inner:Add "ttt_curved_panel_shadow"
	btn.InnerShadow:Dock(FILL)

	btn.Fill = btn.InnerShadow:Add "ttt_curved_panel"
	btn.Fill:Dock(FILL)

	btn.Label = btn.Fill:Add "DLabel"
	btn.Label:SetContentAlignment(5)
	btn.Label:SetFont "tttrw_tab_selector"
	btn.Label:Dock(FILL)
	btn.Label:SetText(text)
	btn.Label:SetTextColor(white_text)


	btn.SetRealColor = btn.SetColor
	function btn:SetColor(col)
		self.Fill:SetColor(col)
	end

	function btn.DoClick()
		if (not doclick or not doclick()) then
			self:Remove()
		end
	end

	btn:SetColor(solid_color)

	btn.InnerShadow:DockPadding(2, 2, 2, 2)

	btn.InnerShadow:SetColor(outline)
	btn.Inner:SetColor(outline)
	btn:SetRealColor(outline)
	btn.InnerShadow:SetCurve(4)
	btn.Inner:SetCurve(4)
	btn:SetCurve(4)
	btn.Fill:SetCurve(2)

	btn:Dock(TOP)
	btn:DockMargin(0, 0, 0, 12)
	btn:SetTall(30)

	self.ButtonCount = self.ButtonCount + 1
	if (self.ButtonCount <= 5) then
		self:SetTall(self:GetTall() + btn:GetTall() + 12)
	end

	return btn
end

vgui.Register("tttrw_dropdown", PANEL, "ttt_curved_panel_shadow")