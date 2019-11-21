
ttt.Notifications = ttt.Notifications or {}


if (SERVER) then
	util.AddNetworkString("ttt.Notifications")

	function PLAYER:Notify(msg)
		net.Start("ttt.Notifications")
			net.WriteString(msg)
		net.Send(self)
	end
else
	local textheight = math.Round(ScrH() / 80)
	surface.CreateFont("ttt_notifications", {
		font = 'Lato',
		size = textheight,
		weight = 200,
	})

	if (not IsValid(ttt.NotifyContainer)) then
		ttt.NotifyContainer = GetHUDPanel():Add "EditablePanel"
	end
	ttt.NotifyContainer:Dock(RIGHT)
	net.Receive("ttt.Notifications", function()
		ttt.Notifications.Add(net.ReadString())
	end)
	ttt.NotifyContainer:SetWide(textheight * 25)

	ttt.Notifications.NotificationList =  {}

	local lifetime = 8
	function ttt.Notifications.Add(msg)
		local p = ttt.NotifyContainer:Add "notify_panel"
		p:Dock(TOP)
		p:InvalidateParent(true)
		p:SetText(msg)
		p.Start = CurTime()
		p.End = CurTime() + 3
	end

	local PANEL = {}
	function PANEL:Init()
		self.Text = self:Add "ttt_centered_wrap"
		self.Text:Dock(FILL)
		self:SetCurve(8)
		self.Text:DockPadding(8, 5, 8, 7)
		self:DockMargin(0, 0, 0, 6)
	end
	function PANEL:Think()
		self:SetColor(ColorAlpha(Color(12, 13, 12), 100 + 100 * (1 - (CurTime() - self.Start) / (self.End - self.Start))))
		if (CurTime() > self.End) then
			self:Remove()
		end
	end
	function PANEL:SetText(t)
		self:InvalidateLayout(true)
		self.Text:SetFont "ttt_notifications"
		self.Text:SetText(t)
		self:SetTall(self.Text:GetTall() + 14)
	end
	vgui.Register("notify_panel", PANEL, "ttt_curved_panel")
end
