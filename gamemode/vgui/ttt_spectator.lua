local PANEL = {}

function PANEL:Init()
	self:OnScreenSizeChanged()
	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
end

function PANEL:OnScreenSizeChanged()
	self:SetCurve(self:GetParent():GetCurve())
	self:DockPadding(self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2)
end

vgui.Register("ttt_spectator_bar", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(1)
	self:OnScreenSizeChanged()
	self:InvalidateLayout(true)

	self.Inner = self:Add "ttt_spectator_bar"
	self.Inner:SetCurve(self:GetCurve())
	self.Inner:Dock(FILL)
	self.Inner:SetZPos(0)

	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_spectator_font"
	self.Text:SetTextColor(white_text)
	self.Text:Dock(FILL)
	self.Text:SetText "Spectating"
	self.Text:SetContentAlignment(5)
	self.Text:SetZPos(1)

	self:SetSkin "tttrw"
	self:InvalidateLayout(true)

	hook.Add("PlayerTick", self, self.Tick)
end

function PANEL:Tick()
	local targ = LocalPlayer():GetObserverTarget()
	if (IsValid(targ)) then
		self:SetVisible(true)
		self.Text:SetText("Spectating " .. targ:Nick())
	else
		self:SetVisible(false)
	end
end

function PANEL:PerformLayout(w, h)
	surface.CreateFont("ttt_spectator_font", {
        font = "Lato",
        size = h * 0.6,
		weight = 1000
    })
end

function PANEL:AcceptInput(key, value)
	self.BaseClass.AcceptInput(self, key, value)
	if (key == "color") then
		self.Inner.Inner:SetColor(Color(unpack(value)))
	elseif (key == "outline_color") then
		self.Inner:SetColor(Color(unpack(value)))
	end
end

vgui.Register("ttt_spectator", PANEL, "ttt_hud_customizable")