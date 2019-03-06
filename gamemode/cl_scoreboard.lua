local pad = 4

vgui.Register("ttt_scoreboard", {
	Init = function(self)

		self.title = vgui.Create("ttt_scoreboard_title", self)
		self.title:SetZPos(-10)

		self.players = {}

		for _, ply in pairs(player.GetAll()) do
			self:CreatePlayerLine(ply)
		end

		self:DockPadding(pad, pad, pad, pad)
		hook.Add("PlayerConnected", self, self.PlayerConnected)
	end,
	ReorderPlayers = function(self)
		for i = #self.players, 1, -1 do
			local pnl = self.players[i]
			if (not IsValid(pnl) or pnl:IsMarkedForDeletion()) then
				table.remove(self.players, i)
			end
		end
		table.sort(self.players, function(a, b)
			return a:GetZPos() < b:GetZPos()
		end)

		for z, pnl in ipairs(self.players) do
			pnl:SetZPos(z)
			pnl.Index = z
		end
	end,
	CreatePlayerLine = function(self, ply, info)
		local pnl = vgui.Create("ttt_scoreboard_player", self)
		self.players[#self.players + 1] = pnl
		pnl:SetPlayer(ply)
		if (info) then
		   pnl:OverrideInfo(info)
		end
		pnl:SetZPos(#self.players)
		self:ReorderPlayers()
	end,
	PlayerConnected = function(self, ply, info)
		self:CreatePlayerLine(ply, info)
	end,
	PerformLayout = function(self, w, h)
		self:SizeToChildren(false, true)
		self:SetTall(self:GetTall())
		self:SetWide(math.max(600, ScrW() / 2))
		self:Center()
	end,
	Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 220)
		surface.DrawRect(0, 0, w, h)
	end
}, "EditablePanel")

local text_height = math.max(16, math.ceil(ScrH() / 70))

surface.CreateFont("ttt_scoreboard_font", {
	font = "Lato",
	size = text_height
})

surface.CreateFont("ttt_scoreboard_small", {
	font = "Lato",
	size = text_height / 3 * 2
})

vgui.Register("ttt_scoreboard_title", {
	Init = function(self)
		self:Dock(TOP)
		self.Name = vgui.Create("DLabel", self)
		self.Name:SetPaintBackground(false)
		self.Name:SetFont "ttt_scoreboard_font"
		self.Name:SetText(GetHostName())

		self.Rounds = vgui.Create("DLabel", self)
		self.Rounds:SetPaintBackground(false)
		self.Rounds:SetFont "ttt_scoreboard_small"
		self:SetRounds(8)
		self:DockMargin(0, 0, 0, pad)
	end,
	SetRounds = function(self, rounds)
		self.Rounds:SetText("Rounds left: " .. rounds)
		self.Rounds:SizeToContents()
	end,
	PerformLayout = function(self, w)
		self:SetTall(text_height + pad * 2)
		self.Name:SizeToContents()
		self.Name:Center()

		self.Rounds:SizeToContents()
		self.Rounds:SetPos(w - self.Rounds:GetWide() - pad, 0)
	end
}, "Panel")

vgui.Register("ttt_scoreboard_player_info", {
	Colors = {
		Color(20, 20, 20, 150),
		Color(90, 90, 90, 50)
	},
	Init = function(self)
		self:SetMouseInputEnabled(false)
	end,
	SetFont = function(self, font)
		self.Font = font
	end,
	SetTextColor = function(self, col)
		self.TextColor = col
	end,
	GetFont = function(self)
		return self.Font
	end,
	SetText = function(self, text)
		self.Text = text
	end,
	Paint = function(self, w, h)
		if (self.Index) then
			surface.SetDrawColor(self.Colors[self.Index])
			surface.DrawRect(0, 0, w, h)
			surface.SetFont(self.Font)
			local tw, th = surface.GetTextSize(self.Text)
			hud.DrawTextShadowed(self.Text, self.TextColor, color_black, w / 2 - tw / 2 - 1, h / 2 - th / 2 - 1, 1, 1)
		else
			surface.SetFont(self.Font)
			local tw, th = surface.GetTextSize(self.Text)
			hud.DrawTextShadowed(self.Text, self.TextColor, color_black, 0, h / 2 - th / 2 - 1, 1, 1)
		end
	end,
	PerformLayout = function(self, w, h)
		self:SetTall(self:GetParent():GetTall())
	end
}, "Panel")

vgui.Register("ttt_scoreboard_player_marker", {
	Init = function(self)
	
		self:SetZPos(1)
		self:Dock(TOP)
		self:SetTall(100)
	end,
	Paint = function(self, w, h)
		surface.SetDrawColor(0,0,255,255)
		surface.SetTexture(surface.GetTextureID "error")
		surface.DrawTexturedRect(0,0,w,h)
	end,
}, "EditablePanel")

vgui.Register("ttt_scoreboard_player", {
	Colors = {
		Color(20, 20, 20, 150),
		Color(90, 90, 90, 100),
	},
	Init = function(self)
		self.Main = vgui.Create("ttt_scoreboard_player_main", self)
		self.Main:Dock(TOP)
		self:DockPadding(pad, 0, 0, 0)
		self:Dock(TOP)
	end,
	Paint = function(self, w, h)
		local role = self.Player:GetRole()
		if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_PREPARING and role ~= "Spectator"
			and IsValid(self.Player.HiddenState) and not self.Player.HiddenState:IsDormant()) then
			local col = ColorAlpha(
				ttt.GetRoleColor(self.Player:GetRole()),
				(self.Index % #self.Colors + 1) * 40 + 80
			)
			surface.SetDrawColor(col)
			surface.DrawRect(0, 0, w, h)
		else
			surface.SetDrawColor(self.Colors[self.Index % #self.Colors + 1])
			surface.DrawRect(0, 0, w, h)
		end
	end,
	Resize = function(self)
		timer.Simple(0, function()
			self:InvalidateLayout(true)
			self:SizeToChildren(false, true)
		end)
	end,
	OnChildAdded = function(self)
		self:Resize()
	end,
	OnChildRemoved = function(self)
		self:Resize()
	end,
	OverrideInfo = function(self, info)
		self.Main:SetText(info.name)
	end,
	SetPlayer = function(self, ply)
		self.Player = ply
		self.Main:SetPlayer(ply)
	end,
}, "EditablePanel")

vgui.Register("ttt_scoreboard_player_main", {
	Init = function(self)
		self:Dock(TOP)
		self:SetCursor "hand"
		self.Name = vgui.Create("ttt_scoreboard_player_info", self)

		self.Name:SetFont "ttt_scoreboard_font"
		self.Name:SetTextColor(Color(234,234,234,255))
		self.Name:Dock(LEFT)

		self.Ping = vgui.Create("ttt_scoreboard_player_info", self)
		self.Ping:SetFont "ttt_scoreboard_small"
		self.Ping:SetTextColor(Color(234,234,234,255))
		self.Ping:Dock(RIGHT)
		surface.SetFont(self.Ping:GetFont())
		local max_wid = surface.GetTextSize "999ms+"
		self.Ping:SetSize(max_wid + pad * 2, self:GetTall())

		self.Karma = vgui.Create("ttt_scoreboard_player_info", self)
		self.Karma:SetFont "ttt_scoreboard_small"
		self.Karma:SetTextColor(Color(234,234,234,255))
		self.Karma:Dock(RIGHT)
		self.Karma:SetText "1000"
		surface.SetFont(self.Karma:GetFont())
		max_wid = surface.GetTextSize(1000)
		self.Karma:SetSize(max_wid + pad * 2, self:GetTall())

		self.Karma:SetZPos(1)
		self.Karma.Index = 1
		self.Ping:SetZPos(0)
		self.Ping.Index = 2
		self:SetPing(100)

		hook.Add("PlayerKarmaUpdate", self, self.PlayerKarmaUpdate)
		hook.Add("PlayerDisconnected", self, self.PlayerDisconnected)
	end,
	OnMousePressed = function(self, code)
		if (code == MOUSE_LEFT) then
			self:DoClick()
		elseif (code == MOUSE_RIGHT) then
			self:DoRightClick()
		end
	end,
	DoClick = function(self)
		if (not IsValid(self.Marker)) then
			self.Marker = vgui.Create("ttt_scoreboard_player_marker", self:GetParent())
			self.Marker:SetTall(self:GetTall())
		else
			self.Marker:Remove()
		end
	end,
	PlayerKarmaUpdate = function(self, ply, karma)
		if (ply == self.Player) then
			self.Karma:SetText(karma)
		end
	end,
	OverrideInfo = function(self, info)
		self.Name:SetText(info.name)
	end,
	SetPing = function(self, ping)
		local text
		if (ping > 999) then
			text = "999ms+"
		else
			text = ping .. "ms"
		end
		self.Ping:SetText("999ms+")
	end,
	PlayerDisconnected = function(self, ply)
		if (self.Player == ply) then
			self:Remove()
			self:GetParent():ReorderPlayers()
		end
	end,
	PerformLayout = function(self, w, h)
		self:SetTall(text_height + pad * 2)
		self.Name:SetWide(w / 2)
	end,
	SetPlayer = function(self, ply)
		self.Player = ply
		self:SetName(ply:Nick())
	end,
	SetName = function(self, name)
		self.Name:SetText(name)
		self.Name:SizeToContents()
	end,
	SetDefault = function(self)
		self:SetName "Name"
	end
}, "EditablePanel")

vgui.Register("ttt_scoreboard_text", {
	Paint = function(self, w, h)
		surface.SetDrawColor(100, 100, 100, 255)
		surface.DrawLine(w - 1, 0, w - 1, h)
	end
}, "DLabel")



function GM:ScoreboardShow()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
	ttt.Scoreboard = vgui.Create "ttt_scoreboard"
	ttt.Scoreboard:MakePopup()
	ttt.Scoreboard:SetKeyboardInputEnabled(false)
end

function GM:ScoreboardHide()
	if (IsValid(ttt.Scoreboard)) then
		ttt.Scoreboard:Remove()
	end
end