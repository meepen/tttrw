local bg_color = Color(13, 12, 13, 0.92 * 255)

local ttt_scoreboard_header_color = Color(20, 19, 20, 0.92 * 255)

surface.CreateFont("ttt_scoreboard_player", {
	font = 'Lato',
	size = ScrH() / 70,
	weight = 300,
})

surface.CreateFont("ttt_scoreboard_header", {
	font = 'Lato',
	size = ScrH() / 20,
	weight = 200
})

surface.CreateFont("ttt_scoreboard_group", {
	font = 'Lato',
	size = ScrH() / 50,
	weight = 200
})

local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(Color(20, 19, 20, 0.92 * 255))

	self.Logo = self:Add "DLabel"
	self.Logo:SetFont "ttt_scoreboard_header"
	
	self:DockPadding(Padding, Padding, Padding, Padding)
end

function PANEL:PerformLayout(w, h)
	self.Logo:SetText "TTT Rewritten"
	self.Logo:SizeToContents()
	self.Logo:SetPos(self:GetWide() / 2 - self.Logo:GetWide() / 2, (self:GetTall() - self.Logo:GetTall())/2)
	self:SetTall(100)
end

vgui.Register("ttt_scoreboard_header", PANEL, "ttt_curved_panel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(Color(70, 102, 135, 0.8 * 255))

	self:DockMargin(Padding * 2, 0, Padding * 2, 4)
	self:DockPadding(4, 4, 4, 4)
	self:Dock(TOP)
	self:SetTall(40)

	self.Avatar = self:Add "AvatarImage"
	self.Avatar:SetWide(32)
	self.Avatar:Dock(LEFT)

	self.Name = self:Add "DLabel"
	self.Name:SetFont "ttt_scoreboard_player"
	self.Name:DockMargin(10, 0, 0, 0)
	self.Name:SetText("Name")
	self.Name:SizeToContents()
	self.Name:Dock(LEFT)

	self.Ping = self:Add "DLabel"
	self.Ping:SetFont "ttt_scoreboard_player"
	self.Ping:DockMargin(0, 0, 10, 0)
	self.Ping:SetText "Ping"
	self.Ping:SizeToContents()
	self.Ping:Dock(RIGHT)

	self.Karma = self:Add "DLabel"
	self.Karma:SetFont "ttt_scoreboard_player"
	self.Karma:DockMargin(0, 0, Padding * 10, 0)
	self.Karma:SetText "Karma"
	self.Karma:SizeToContents()
	self.Karma:Dock(RIGHT)
end

function PANEL:Paint(w, h)
	if (IsValid(self.Player)) then
		if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_PREPARING and IsValid(self.Player.HiddenState) and not self.Player.HiddenState:IsDormant()) then
			self:SetColor(ColorAlpha(self.Player:GetRoleData().Color, 100))
			-- TODO(meep): event based hook
		end
		self.Ping:SetText(self.Player:Ping() .. "ms")
		self.Ping:SizeToContents()
		self.Ping:Dock(RIGHT)
		self.Karma:DockMargin(0, 0, Padding * 12 - self.Ping:GetWide(), 0)
	end

	BaseClass.Paint(self, w, h)
end

function PANEL:SetPlayer(ply)
	if (not IsValid(ply)) then
		return
	end

	self.Player = ply
	self.Avatar:SetPlayer(ply)

	self.Name:SetText(ply:Nick())
	self.Name:SizeToContents()
	self.Name:Dock(LEFT)

	self.Karma:SetText "1000"
	self.Karma:SizeToContents()
	self.Karma:Dock(RIGHT)
end

vgui.Register("ttt_scoreboard_player", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(color_white)
	self.Plys = {}
	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_scoreboard_group"
	self:Dock(TOP)
	self:DockMargin(Padding, Padding / 2, Padding, Padding / 2)
end

function PANEL:SetText(txt)
	self.Text:SetText(txt)
	self.Text:SizeToContents()
	self:SetTall(self.Text:GetTall()+1)
	self:DockPadding(20, 0, 0, 2)
	self.Text:Dock(LEFT)
end

function PANEL:SetPlayers(plys)
	if (table.Count(plys) <= 0) then return end

	for i, v in pairs(plys) do
		local pnl = self:GetParent():Add "ttt_scoreboard_player"
		pnl:SetPlayer(v)
		self.Plys[i] = pnl
	end
end

vgui.Register("ttt_scoreboard_group", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self:SetColor(bg_color)
	self:SetCurve(4)

	self:SetWide(ScrW() - ScrW() / 3)
	self:SetTall(1000)

	self.Contents = {}

	self.Header = self:Add "ttt_scoreboard_header"
	self.Header:Dock(TOP)

	self.Guide = self:Add "ttt_scoreboard_player"
	self.Guide:SetColor(ttt_scoreboard_header_color)
	self.Guide:DockMargin(Padding * 2, 10, Padding * 2, Padding / 4)
	self.Guide.Karma:DockMargin(0, 0, Padding * 12 - self.Guide.Ping:GetWide() - 10, 0)
	self.Guide.Name:DockMargin(42, 0, 0, 0)
	self.Guide.Avatar:Remove()

	local living = {}
	local dead = {}
	local spectators = {}
	local unidentified = {}
	local connecting = {}

	for _, ply in pairs(player.GetAll()) do
		local result_tbl = living
		
		if (ply:Team() == TEAM_CONNECTING) then
			result_tbl = connecting
		elseif (ply:Team() == TEAM_SPECTATOR) then
			result_tbl = spectators
		elseif (not ply:Alive() and IsValid(ply.DeadState)) then
			result_tbl = ply.DeadState:GetIdentified() and dead or unidentified
		end

		table.insert(result_tbl, ply)
	end

	self:AddGroup("Living", Color(50, 200, 100), living)
	self:AddGroup("Unidentified", Color(150, 50, 50), unidentified)
	self:AddGroup("Dead", Color(200, 50, 50), dead)
	self:AddGroup("Spectators", color_white, spectators)
	self:AddGroup("Connecting", color_white, connecting)
	self:InvalidateLayout()

	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
end

function PANEL:AddGroup(name, color, plys)
	local pnl = self:Add "ttt_scoreboard_group"

	pnl:SetColor(color)
	pnl:SetText(name)
	pnl:SetPlayers(plys)
	pnl:Dock(TOP)

	table.insert(self.Contents, pnl)
end

vgui.Register("ttt_scoreboard", PANEL, "ttt_curved_panel")