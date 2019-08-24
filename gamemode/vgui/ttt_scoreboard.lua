local bg_color = Color(13, 12, 13, 0.92 * 255)

local ttt_scoreboard_header_color = Color(20, 19, 20, 0.92 * 255)

surface.CreateFont("ttt_scoreboard_player", {
	font = 'Lato',
	size = ScrH() / 65,
	weight = 300,
})

surface.CreateFont("ttt_scoreboard_header", {
	font = 'Lato',
	size = ScrH() / 20,
	weight = 200
})

surface.CreateFont("ttt_scoreboard_group", {
	font = 'Lato',
	size = ScrH() / 80,
	weight = 0
})

local Padding = math.Round(ScrH() * 0.0075)
local Curve = math.Round(Padding / 2)

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(bg_color)
	self.Logo = self:Add "DLabel"
	self.Logo:SetFont "ttt_scoreboard_header"
	
	self:DockPadding(Padding, Padding, Padding, Padding)
end

function PANEL:PerformLayout(w, h)
	self.Logo:SetText "TTT Rewrite"
	self.Logo:SizeToContents()
	self.Logo:SetPos(self:GetWide() / 2 - self.Logo:GetWide() / 2, (self:GetTall() - self.Logo:GetTall())/2)
	self:SetTall(self.Logo:GetTall() + Padding * 2)
	self.Logo:Center()

	BaseClass.PerformLayout(self, self:GetSize())
end

vgui.Register("ttt_scoreboard_header", PANEL, "ttt_curved_panel")

local PANEL = {}

DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(math.Round(Padding / 2))
	self:SetColor(Color(70, 102, 135, 0.8 * 255))

	self:DockMargin(Padding, 0, Padding, Padding)
	self:DockPadding(Padding / 2, Padding / 2, Padding / 2, Padding / 2)
	self:Dock(TOP)
	surface.SetFont "ttt_scoreboard_player"
	local _, h = surface.GetTextSize "A"
	self:SetTall(h + Padding)

	self.Avatar = self:Add "AvatarImage"
	self.Avatar:Dock(LEFT)
	function self.Avatar:PerformLayout(w, h)
		self:SetWide(h)
	end

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
		self.Karma:DockMargin(0, 0, Padding * 12 - self.Ping:GetWide(), 0)
	end

	BaseClass.Paint(self, w, h)
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)
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
	self.Render = self:Add "ttt_scoreboard_group_header_render"
	self.Render:Dock(LEFT)
	self:DockMargin(Padding * 6, 0, 0, 0)
end
function PANEL:SetColor(col)
	self.Render:SetColor(col)
end
function PANEL:SetText(text)
	self.Render:SetText(text)
end
function PANEL:Paint() end
vgui.Register("ttt_scoreboard_group_header", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(Curve)

	self:DockPadding(Padding, Padding / 4, Padding, Padding / 4)

	self.Text = self:Add "DLabel"
	self.Text:SetFont "ttt_scoreboard_group"

	self:SetText "hi"
end

function PANEL:SetText(txt)
	self.Text:SetText(txt)
	self:SetTall(self.Text:GetTall() + 1)
	self:PerformLayout(self:GetSize())
end

function PANEL:PerformLayout(w, h)
	self.Text:SizeToContents()
	self:SetWide(self:GetParent():GetWide() / 9)

	self.Text:Center()
	BaseClass.PerformLayout(self, self:GetSize())
end

vgui.Register("ttt_scoreboard_group_header_render", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self.Players = {}
	self:Dock(TOP)
	self:DockMargin(Padding, 0, Padding, Padding)

	self.Header = self:Add "ttt_scoreboard_group_header"
	self.Header:Dock(TOP)
	self.Header:SetZPos(0)

	self:SetColor(color_white)
end

function PANEL:SetColor(col)
	self.Header:SetColor(col)
end

function PANEL:SetPlayers(plys)
	for i, v in pairs(plys) do
		local pnl = self:Add "ttt_scoreboard_player"
		pnl:DockMargin(0, Padding / 2, 0, 0)
		pnl:SetPlayer(v)
		pnl:SetZPos(i)
		self.Players[i] = pnl
	end
end

function PANEL:SetText(text)
	self.Header:SetText(text)
end

function PANEL:PerformLayout()
	self:SetSize(self:ChildrenSize())
end

vgui.Register("ttt_scoreboard_group", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetColor(bg_color)
	self:SetCurve(4)

	self:SetWide(ScrW() - ScrW() / 3)

	self.Contents = {}

	self.Guide = self:Add "ttt_scoreboard_player"
	self.Guide:SetColor(ttt_scoreboard_header_color)
	self.Guide:DockMargin(Padding * 2, 10, Padding * 2, Padding / 4)
	self.Guide.Karma:DockMargin(0, 0, Padding * 12 - self.Guide.Ping:GetWide() - 10, 0)
	self.Guide.Name:DockMargin(42, 0, 0, 0)
	self.Guide.Avatar:Remove()

	self.Scroller = self:Add "DScrollPanel"
	self.Scroller:Dock(FILL)

	local living = {}
	local dead = {}
	local spectators = {}
	local unidentified = {}
	local connecting = {}

	for _, ply in ipairs(player.GetAll()) do
		local result_tbl = living
		
		if (ply:Team() == TEAM_CONNECTING) then
			result_tbl = connecting
		elseif (ply:Team() == TEAM_SPECTATOR) then
			result_tbl = spectators
		elseif (not ply:Alive() and IsValid(ply.DeadState)) then
			result_tbl = ply.DeadState:GetIdentified() and dead or unidentified
		elseif (not ply:Alive() and LocalPlayer():GetRoleData().Evil) then
			result_tbl = unidentified
		end

		table.insert(result_tbl, ply)
	end

	local alpha = 25

	self:AddGroup("Terrorists", Color(10, 250, 100, alpha), living)
	self:AddGroup("Unidentified", Color(250, 150, 150, alpha), unidentified)
	self:AddGroup("Dead", Color(78, 55, 53, alpha * 3), dead)
	self:AddGroup("Spectators", Color(255, 255, 255, alpha), spectators)
	self:AddGroup("Connecting", Color(255, 255, 255, alpha), connecting)
	self:InvalidateLayout()

	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
end

function PANEL:AddGroup(name, color, plys)
	local pnl = self.Scroller:Add "ttt_scoreboard_group"

	pnl:SetColor(color)
	pnl:SetText(name)
	pnl:SetPlayers(plys)
	pnl:Dock(TOP)

	table.insert(self.Contents, pnl)
end

vgui.Register("ttt_scoreboard_inner", PANEL, "ttt_curved_panel")


local PANEL = {}

function PANEL:Init()
	self.Header = self:Add "ttt_scoreboard_header"
	self.Header:Dock(TOP)
	self.Header:SetTall(100)
	self.Header:DockMargin(0, 0, 0, 1)
	self.Header:SetCurveBottomLeft(false)
	self.Header:SetCurveBottomRight(false)
	
	self.Inner = self:Add "ttt_scoreboard_inner"
	self.Inner:Dock(FILL)
	self.Inner:SetCurveTopLeft(false)
	self.Inner:SetCurveTopRight(false)
end

vgui.Register("ttt_scoreboard", PANEL, "EditablePanel")