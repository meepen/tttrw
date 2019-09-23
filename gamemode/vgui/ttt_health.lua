
local PANEL = {}

function PANEL:GetHealthFraction()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		return 1
	end

	return targ:Health() / targ:GetMaxHealth()
end


function PANEL:PerformLayout()
	self:SetCurve(self:GetParent():GetCurve() / 2)
end

function PANEL:Scissor()
	local x0, y0, x1, y1 = self:GetRenderBounds()
	local w = math.min(x1 - x0, self:GetWide() * self:GetHealthFraction())
	render.SetScissorRect(x0, y0, x0 + w, y1, true)
end

vgui.Register("ttt_health_bar_inner", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self.Inner = self:Add "ttt_health_bar_inner"
	self.Inner:Dock(FILL)
	self.Inner:SetColor(Color(59, 170, 91))
end

function PANEL:PerformLayout()
	self:SetCurve(self:GetParent():GetCurve())
	self:DockPadding(self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2)
end

vgui.Register("ttt_health_bar", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self:OnScreenSizeChanged()
	self:InvalidateLayout(true)

	self.Inner = self:Add "ttt_health_bar"
	self.Inner:SetColor(white_text)
	self.Inner:SetCurve(self:GetCurve())
	self.Inner:Dock(FILL)
	self.Inner:SetZPos(0)

	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_health_font"
	self.Text:SetTextColor(white_text)
	self.Text:Dock(FILL)
	self.Text:SetText "1/1"
	self.Text:SetContentAlignment(5)
	self.Text:SetZPos(1)

	self:SetSkin "tttrw"
	self:InvalidateLayout(true)
	hook.Add("PlayerTick", self, self.Tick)
end

function PANEL:Think()
	local targ = ttt.GetHUDTarget()
	if (not IsValid(targ)) then
		self.Text:SetText "AJSDUASJDA"
	else
		self.Text:SetText(string.format("%i / %i", targ:Health(), targ:GetMaxHealth()))
	end
end

function PANEL:Tick()
	local targ = ttt.GetHUDTarget()
	if (IsValid(targ) and targ:Alive()) then
		self:SetVisible(true)
	else
		self:SetVisible(false)
	end
end

function PANEL:AcceptInput(key, value)
	self.BaseClass.AcceptInput(self, key, value)
	if (key == "color") then
		self.Inner.Inner:SetColor(Color(unpack(value)))
	elseif (key == "outline_color") then
		self.Inner:SetColor(Color(unpack(value)))
	end
end

function PANEL:PerformLayout(w, h)
	surface.CreateFont("ttt_health_font", {
        font = "Lato",
        size = h * 0.6,
		weight = 1000
    })
end

vgui.Register("ttt_health", PANEL, "ttt_hud_customizable")