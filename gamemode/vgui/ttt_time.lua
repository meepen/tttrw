
local PANEL = {}

function PANEL:Init()
	self.RoleText = self:Add "DLabel"
	self.RoleText:SetFont "ttt_time_font"
	self.RoleText:Dock(FILL)
	self.RoleText:SetContentAlignment(4)
	self.RoleText:SetZPos(1)
	self.RoleText:SetTextColor(white_text)

	self.TimeText = self:Add "DLabel"
	self.TimeText:SetFont "ttt_time_font"
	self.TimeText:Dock(FILL)
	self.TimeText:SetContentAlignment(6)
	self.TimeText:SetZPos(1)
	self.TimeText:SetTextColor(white_text)
end

function PANEL:OnRoleChange(new)
	self:SetColor(ttt.roles[new].Color)
	self.RoleText:SetText(ttt.roles[new].Name)
end

function PANEL:SetToRound()
	if (ttt.GetRoundState) then
		self.RoleText:SetText(ttt.Enums.RoundState[ttt.GetRoundState()])
	end
	self:SetColor(Color(154, 153, 153))
end

function PANEL:Think()
	local targ = ttt.GetHUDTarget()

	if (IsValid(targ) and targ:Alive() and IsValid(targ.HiddenState) and not targ.HiddenState:IsDormant()) then
		if (self.LastRole ~= targ:GetRole()) then
			self:OnRoleChange(targ:GetRole())
			self.LastRole = targ:GetRole()
		end
	elseif (self.LastRole ~= "ended") then
		self.LastRole = "ended"
		self:SetToRound()
	end

	if (ttt.GetRealRoundEndTime) then

		local ends = ((not LocalPlayer():Alive() or LocalPlayer():GetRoleData().Evil) and ttt.GetRealRoundEndTime or ttt.GetVisibleRoundEndTime)()
		local starts = ttt.GetRoundStateChangeTime()

		if (ends < CurTime()) then
			self.TimeText:SetText "Overtime"
		else
			self.TimeText:SetText(string.FormattedTime(math.max(0, ends - CurTime()), "%i:%02i"))
		end
	end
end

function PANEL:PerformLayout()
	self:SetCurve(self:GetParent():GetCurve() / 2)
	self:DockPadding(self:GetCurve() + self:GetWide() * 0.15, self:GetCurve(), self:GetCurve() + self:GetWide() * 0.15, self:GetCurve())
end

vgui.Register("ttt_time_bar_inner", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self:OnScreenSizeChanged()
	self.Inner = self:Add "ttt_time_bar_inner"
	self.Inner:Dock(FILL)
end

function PANEL:OnScreenSizeChanged()
	self:SetCurve(self:GetParent():GetCurve())
	self:DockPadding(self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2, self:GetCurve() / 2)
end

vgui.Register("ttt_time_bar", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self:OnScreenSizeChanged()
	self:InvalidateLayout(true)

	self.Inner = self:Add "ttt_time_bar"
	self.Inner:SetColor(white_text)
	self.Inner:SetCurve(self:GetCurve())
	self.Inner:Dock(FILL)

	self:SetSkin "tttrw"
end

function PANEL:AcceptInput(key, value)
	self.BaseClass.AcceptInput(self, key, value)
	if (key == "outline_color") then
		self.Inner:SetColor(Color(unpack(value)))
	end
end

function PANEL:PerformLayout(w, h)
	surface.CreateFont("ttt_time_font", {
        font = "Lato",
        size = h * 0.6,
		weight = 1000
    })
end

vgui.Register("ttt_time", PANEL, "ttt_hud_customizable")