local bg_color = Color(17, 15, 13, 0.75 * 255)

local ttt_scoreboard_header_color = Color(20, 19, 20, 0.92 * 255)

surface.CreateFont("ttt_scoreboard_player", {
	font = "Lato",
	size = math.max(11, ScrH() / 120) * 2,
	weight = 300,
})

surface.CreateFont("ttt_scoreboard_status", {
	font = "Roboto",
	size = math.max(ScrH() / 80, 18),
	weight = 0,
	italic = true
})

surface.CreateFont("ttt_scoreboard_info", {
	font = "Roboto",
	size = math.max(ScrH() / 75, 18),
	weight = 0,
})

surface.CreateFont("ttt_scoreboard_rank", {
	font = "Roboto",
	size = math.max(ScrH() / 180, 9) * 2,
	weight = 0,
	italic = false
})

surface.CreateFont("ttt_scoreboard_header", {
	font = "Roboto",
	size = 70,
	weight = 200,
})

surface.CreateFont("ttt_scoreboard_group", {
	font = "Roboto",
	size = math.max(16, ScrH() / 80),
	weight = 400,
})

local Padding = math.Round(ScrH() * 0.008)
local Curve = math.Round(Padding / 2)
local Slant = Padding * 5

function GM:TTTGetScoreboardLogoPanel()
	return "tttrw_scoreboard_header_logo"
end

local PANEL = {}

function PANEL:Init()
	self:SetFont "ttt_scoreboard_header"
	self:SetText "TTT Rewrite"
	self:SizeToContents()
	self:SetContentAlignment(5)
	self:Dock(LEFT)
end

vgui.Register("tttrw_scoreboard_header_logo", PANEL, "DLabel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(6)
	self:SetTall(32)
	self:SetColor(outline)

	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Inner:SetColor(main_color)
	self.Inner:SetCurve(6)

	local pnl = hook.Run "TTTGetScoreboardLogoPanel"
	self.Logo = self:Add(pnl)
	if (not IsValid(self.Logo)) then
		ErrorNoHalt("Couldn't create Logo Panel: " .. pnl)
		self.Logo = self:Add "tttrw_scoreboard_header_logo"
	end

	self:SetTall(self.Logo:GetTall() + Padding * 2)

	self.RoundNumber = self:Add "DLabel"
	self.RoundNumber:SetFont "ttt_scoreboard_rank"
	
	self.Inner:SetCurveBottomLeft(false)
	self.Inner:SetCurveBottomRight(false)
	self:SetCurveBottomLeft(false)
	self:SetCurveBottomRight(false)
end

function PANEL:Think()
	self.RoundNumber:SetText(string.format("Round %i", ttt.GetRoundNumber()))
	self.RoundNumber:SizeToContents()
	self.RoundNumber:SetPos(self:GetWide() - self.RoundNumber:GetWide() - 5, self:GetTall() - self.RoundNumber:GetTall())
end

vgui.Register("tttrw_scoreboard_header", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Text = self.Inner:Add "DLabel"
	self.Text:SetContentAlignment(5)
	self.Text:Dock(FILL)
	self.Color = outline
end

function PANEL:SetText(t)
	self.Text:SetText(t)
	self:SizeToContents()
end

function PANEL:SetTextColor(col)
	self.Text:SetTextColor(col)
end

function PANEL:SetFont(f)
	self.Text:SetFont(f)
	self:SizeToContents()
end

function PANEL:SizeToContents()
	self.Text:SizeToContents()
	local w, h = self.Text:GetSize()

	self:SetSize(w + Padding * 2, h + 4)

	self.Text:Center()
end

function PANEL:SetCurve(curve)
	self.Curve = curve
	self.Inner:SetCurve(curve)
end

function PANEL:SetColor(col)
	self.Inner:SetColor(col)
end

DEFINE_BASECLASS "ttt_curved_panel_outline"

vgui.Register("ttt_scoreboard_rank", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self:SetText ""

	self.Text = self:Add "DLabel"
	self.Text:Dock(FILL)
	self.Text:SetContentAlignment(5)
	self.Text:SetFont "ttt_scoreboard_status"
	self.Text:SetTextColor(white_text)

	function self.Text:Paint(w, h)
		draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2, self:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
	end

	self:SetStatus(ttt.STATUS_DEFAULT)
	self:SetColor(Color(0, 0, 0, 0))

	surface.SetFont(self.Text:GetFont())
	local max_w = 0
	for k, data in pairs(ttt.Status) do
		local w = surface.GetTextSize(data.text)
		max_w = math.max(max_w, w)
	end

	self:SetWide(max_w + Slant * 2)
end

function PANEL:SetStatus(stat)
	if (stat == self.Status) then stat = ttt.STATUS_DEFAULT end
	self.Status = stat
	self:SetColor(ttt.Status[self.Status].color)
	self.Text:SetText(ttt.Status[self.Status].text)

	if (IsValid(self:GetParent().Player)) then
		ttt.SetPlayerStatus(self:GetParent().Player, stat)
		self:GetParent():GetParent():Toggle()
	end
end

function PANEL:DoClick()
	self:GetParent():DoClick()
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(self:GetColor())
	draw.NoTexture()
	if (self.Rect) then
		surface.DrawPoly(self.Rect)
	end
end

function PANEL:PerformLayout(w, h)
	self.Rect = {
		{x = Slant * (h / (h + Padding)), y = 0},
		{x = w, y = 0},
		{x = w - Slant * (h / (h + Padding)), y = h},
		{x = 0, y = h}
	}
end

vgui.Register("ttt_scoreboard_status", PANEL, "DButton")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:DockMargin(0, 0, 0, Padding)
	self:DockPadding(Padding / 2, Padding / 2, Padding / 2, Padding / 2)
	self:Dock(TOP)
	surface.SetFont "ttt_scoreboard_player"
	local _, h = surface.GetTextSize "A"
	self:SetTall(h + Padding)

	self:SetText("")

	self.Avatar = self:Add "AvatarImage"
	self.Avatar:Dock(LEFT)
	function self.Avatar:PerformLayout(w, h)
		self:SetWide(h)
	end

	self.Name = self:Add "DLabel"
	self.Name:SetFont "ttt_scoreboard_player"
	self.Name:DockMargin(10, 0, 0, 0)
	self.Name:SetText("Name")
	self.Name:SizeToContentsX()
	self.Name:Dock(LEFT)
	self.Name:SetTextColor(white_text)
	self.Name:SetContentAlignment(5)

	self.Ping = self:Add "DLabel"
	self.Ping:SetFont "ttt_scoreboard_info"
	self.Ping:DockMargin(0, 0, Padding * 5, 0)
	self.Ping:SetText "Ping"
	self.Ping:SizeToContentsX()
	self.Ping:Dock(RIGHT)
	self.Ping:SetTextColor(white_text)

	self.Karma = self:Add "DLabel"
	self.Karma:SetFont "ttt_scoreboard_info"
	self.Karma:DockMargin(0, 0, Padding, 0)
	self.Karma:SetText "Karma"
	self.Karma:SizeToContentsX()
	self.Karma:Dock(RIGHT)
	self.Karma:SetTextColor(white_text)

	self.RankContainer = self:Add "EditablePanel"
	self.RankContainer:Dock(LEFT)
	self.RankContainer:DockMargin(Padding, 0, 0, 0)
	self.RankContainer:SetMouseInputEnabled(false)

	self.Rank = self.RankContainer:Add "ttt_scoreboard_rank"
	self.Rank:SetColor(Color(0, 0, 0, 0))
	self.Rank:SetFont "ttt_scoreboard_rank"
	self.Rank:SetText "Rank"
	self.Rank:SetTextColor(white_text)
	self.Rank:SetMouseInputEnabled(true)
	self.Rank:SetCurve(4)
	self.Rank:SizeToContents()
	self.Rank:Dock(RIGHT)
	self.Rank:SetZPos(10000)

	self.PlayerSpecific = {}

	self.Status = self:Add "ttt_scoreboard_status"
	
	self.Rank:SetWide(self.Status:GetWide())
end

function PANEL:DoClick()
	self:GetParent():Toggle()
end

function PANEL:OnMousePressed(key)
	if (key == MOUSE_RIGHT) then
		self.Menu = DermaMenu()

		hook.Run("TTTRWPopulateScoreboardOptions", self.Menu, self.Player)

		self.Menu:Open()
	elseif (key == MOUSE_LEFT) then
		self:DoClick()
	end
end

function PANEL:Paint(w, h)
	if (not IsValid(self.Player)) then
		self:SetColor(Color(17, 15, 13, 0.75 * 255))
		return
	end

	surface.SetDrawColor(17, 15, 13, 0.75 * 255)
	ttt.DrawCurvedRect(0, 0, w, h, 4)

	surface.SetDrawColor(self.Player:GetRoleData().Color)
	local x = self:ScreenToLocal(self.RankContainer:LocalToScreen(self.RankContainer:GetSize()))
	ttt.DrawCurvedRect(0, 0, x, h, 4, false, true, true, false)
	surface.DrawPoly {
		{x = x, y = 0},
		{x = x + Slant, y = 0},
		{x = x, y = h}
	}
end

function PANEL:PerformLayout(w, h)
	self.RankContainer:SetWide(w * 0.4 - Slant * 2 - self.Name:GetWide())
	local x = self:ScreenToLocal(self.RankContainer:LocalToScreen(self.RankContainer:GetSize()))

	if (IsValid(self.Status)) then 
		self.Status:SetPos(x + 19, Padding / 2)
	end
end

function PANEL:Think()
	local ply = self.Player
	if (not IsValid(ply)) then
		self:Remove()
	else
		self.Karma:SetText(ply:GetKarma())
	end
end

function PANEL:SetPlayer(ply)
	if (not IsValid(ply)) then
		return
	end

	self.Player = ply
	self.Avatar:SetPlayer(ply)

	self.Name:SetText(ply:Nick())
	self.Name:SizeToContentsX()
	if (self.Name:GetWide() > 250) then -- wtf
		self.Name:SetWide(250)
	end
	self.Name:Dock(LEFT)

	self.Karma:SetText "1000"
	self.Karma:SizeToContentsX()
	self.Karma:Dock(RIGHT)

	self.Ping:SetText(self.Player:Ping() .. "ms")
	self.Ping:SizeToContentsX()
	self.Karma:DockMargin(0, 0, Padding * 12 - self.Ping:GetWide(), 0)

	local col = hook.Run("TTTGetPlayerColor", ply) or color_white
	if (col.a < 1) then
		self.Rank:SetVisible(false)
	else
		self.Rank:SetColor(ColorAlpha(col, 0.9 * 255))
		self.Rank:SetText(hook.Run("TTTGetRankPrintName", ply:GetUserGroup()) or ply:GetUserGroup())
		self.Rank:SizeToContents()
	end

	hook.Run("TTTRWScoreboardPlayer", self.Player, function()
		local pnl = self.RankContainer:Add "ttt_scoreboard_rank"
		pnl:SetColor(Color(0, 0, 0, 255))
		pnl:SetFont "ttt_scoreboard_rank"
		pnl:SetText "Panel"
		pnl:SetTextColor(white_text)
		pnl:SetMouseInputEnabled(false)
		pnl:SetCurve(4)
		pnl:Dock(LEFT)
		pnl:SizeToContents()
		pnl:DockMargin(0, 0, 2, 0)

		table.insert(self.PlayerSpecific, pnl)

		return pnl
	end)

	self.Status:SetStatus(ttt.GetPlayerStatus(self.Player))
	self:GetParent():Toggle()
end

DEFINE_BASECLASS "ttt_curved_button"
function PANEL:OnRemove()
	if (IsValid(self.Menu)) then
		self.Menu:Remove()
	end
	if (BaseClass.OnRemove) then
		BaseClass.OnRemove(self)
	end
end

vgui.Register("ttt_scoreboard_player_render", PANEL, "DButton")

local PANEL = {}

function PANEL:Init()
	self.Statuses = {}
	self:DockPadding(0, 0, Padding * Padding, 0)
	self:DockMargin(0, -Padding/4, 0, 0)
	
	for STATUS = ttt.STATUS_MISSING, ttt.STATUS_FRIEND do
		self.Statuses[STATUS] = self:Add "ttt_scoreboard_status"
		self.Statuses[STATUS]:SetStatus(STATUS)
		self.Statuses[STATUS]:Dock(RIGHT)
		self.Statuses[STATUS].DoClick = function()
			self:GetParent().Render.Status:SetStatus(STATUS)
		end
	end
end

vgui.Register("ttt_scoreboard_statuses", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Expanded = false

	self:DockMargin(0, 0, 0, Padding)

	self.Disabled = false

	surface.SetFont "ttt_scoreboard_player"
	_, self.ContractedSize = surface.GetTextSize "A"
	self:SetTall(self.ContractedSize + Padding)

	self.Render = self:Add "ttt_scoreboard_player_render"
	self.Render:Dock(TOP)
end

function PANEL:SetPlayer(ply)
	self.Render:SetPlayer(ply)

	if (ply == LocalPlayer() and IsValid(self.Render.Status)) then
		self.Render.Status:Remove()
		self:Disable()
	end
end

function PANEL:Disable()
	if (self.Expanded) then self:Toggle() end
	if (self.Disabled) then return end

	self.Disabled = true
end

function PANEL:Toggle()
	if (self.Disabled) then return end
	if (self.Expanded) then
		self:SetTall(self:GetTall()/2)

		if (IsValid(self.Statuses)) then self.Statuses:Remove() end
		
		self.Expanded = false
	else
		self:SetTall(self:GetTall()*2)
		
		self.Statuses = self:Add "ttt_scoreboard_statuses"
		self.Statuses:Dock(TOP)
		self.Statuses:SetTall(self.ContractedSize)
		
		self.Expanded = true
	end
	if (IsValid(self.Group)) then
		self.Group:Resize()
	end
end

vgui.Register("ttt_scoreboard_player", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self.Color = outline
	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Inner:SetColor(main_color)

	self.Text = self.Inner:Add "DLabel"
	self.Text:SetFont "ttt_scoreboard_group"
	
	self:SetText "hi"

	self:Dock(TOP)

	self:SetCurve(6)
	self.Inner:SetCurve(self:GetCurve())

	self:SetCurveBottomLeft(false)
	self:SetCurveBottomRight(false)
	self.Inner:SetCurveBottomLeft(false)
	self.Inner:SetCurveBottomRight(false)
end

function PANEL:SetText(txt)
	self.Text:SetText(txt)
	self.Text:SizeToContents()
	self:SetSize(120, self.Text:GetTall() + 8)
	self:InvalidateLayout(true)
end

function PANEL:PerformLayout(w, h)
	self.Text:Center()
	self:GetParent():SetTall(h)
end

function PANEL:SetColor(c)
	self.Inner:SetColor(c)
end

vgui.Register("ttt_scoreboard_group_header", PANEL, "ttt_curved_panel_outline")


local PANEL = {}

function PANEL:Init()
	self.Players = {}
	self:Dock(TOP)
	self:DockMargin(0, 0, 0, Padding)

	self.HeaderArea = self:Add "EditablePanel"
	self.HeaderArea:Dock(TOP)
	self.HeaderArea:SetZPos(0)
	self.Header = self.HeaderArea:Add "ttt_scoreboard_group_header"
	self.Header:Dock(LEFT)

	self:SetColor(color_white)
end

function PANEL:SetColor(col)
	self.Header:SetColor(col)
end

function PANEL:SetText(text)
	self.Header:SetText(text)
end

function PANEL:AddPlayerPanel(ply, pnl)
	if (self == pnl.Group) then
		return
	end

	local oldgroup = pnl.Group
	if (IsValid(oldgroup)) then
		oldgroup.Players[ply] = nil
		oldgroup:Resize()
	end

	self.Players[ply] = pnl
	pnl.Group = self
	pnl:SetParent(self)
	self:InvalidateChildren(true)
	self:Resize()
end

function PANEL:Resize()
	if (not next(self.Players)) then
		self:SetTall(0)
	else
		self:InvalidateChildren(true)
		self:SizeToChildren(true, true)
	end
end

vgui.Register("ttt_scoreboard_group", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetColor(outline)
	self:SetCurve(6)
	self:SetWide(ScrW() * 2 / 3)
	self:SetCurveTopLeft(false)
	self:SetCurveTopRight(false)

	self.Inner = self:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Inner:SetColor(main_color)
	self.Inner:SetCurve(self:GetCurve())
	self.Inner:SetCurveTopLeft(false)
	self.Inner:SetCurveTopRight(false)

	self.Inner:DockPadding(14, 9, 14, 14)

	self.Groups = {}
	self.Players = {}

	self.Scroller = self.Inner:Add "DScrollPanel"
	self.Scroller:Dock(FILL)

	self:AddGroup("Terrorists", Color(14, 88, 34))
	self:AddGroup("Unidentified", Color(85, 111, 87))
	self:AddGroup("Dead", Color(80, 105, 38))
	self:AddGroup("Spectators", Color(127, 129, 13))
	self:AddGroup("Connecting", Color(20, 22, 32))

	self:CreatePlayers()

	self:Center()
end

function PANEL:GetPlayerPanel(ply)
	local pnl = self.Players[ply]
	if (not IsValid(self.Players[ply])) then
		pnl = vgui.Create "ttt_scoreboard_player"
		pnl:Dock(TOP)
		pnl:DockMargin(0, Padding / 2, 0, 0)
		pnl:SetZPos(ply:UserID())
		pnl:SetPlayer(ply)
		self.Players[ply] = pnl
	end

	return pnl
end

function PANEL:CreatePlayers()
	for ply, pnl in pairs(self.Players) do
		if (not IsValid(ply)) then
			-- TODO(meep): remove panel
			local group = pnl.Group
			pnl:Remove()
			group.Players[ply] = nil
			self.Players[ply] = nil
			group:Resize()
		end
	end

	for _, ply in pairs(player.GetAll()) do
		local group = self:AddGroup(self:GetPlayerCategory(ply))
		local pnl = self:GetPlayerPanel(ply)
		group:AddPlayerPanel(ply, pnl)
	end
end

function PANEL:GetPlayerCategory(ply)
	return hook.Run("TTTRWGetPlayerCategory", ply)
end

function PANEL:AddGroup(name, color)
	local pnl = self.Groups[name]
	if (not IsValid(pnl)) then
		pnl = self.Scroller:Add "ttt_scoreboard_group"
		pnl:SetColor(color)
		pnl:SetText(name)
		pnl:Dock(TOP)
		pnl:Resize()
		self.Groups[name] = pnl
	end

	return pnl
end

function PANEL:Think()
	self:CreatePlayers()
end

function PANEL:GetGroup(name)
	return self.Groups[name]
end

vgui.Register("ttt_scoreboard_inner", PANEL, "ttt_curved_panel_outline")


local PANEL = {}

function PANEL:Init()
	self.Header = self:Add "tttrw_scoreboard_header"
	self.Header:Dock(TOP)
	--self.Header:SetTall(150)
	self.Header:DockMargin(0, 0, 0, 4)
	
	self.Inner = self:Add "ttt_scoreboard_inner"
	self.Inner:Dock(FILL)
end

vgui.Register("ttt_scoreboard", PANEL, "EditablePanel")

function GM:TTTRWPopulateScoreboardOptions(menu, ply)
	menu:AddOption("Open Profile", function()
		ply:ShowProfile()
	end)

	local sid = menu:AddSubMenu "Copy SteamID"

	sid:AddOption("SteamID", function()
		SetClipboardText(ply:SteamID())
	end)
	sid:AddOption("SteamID64", function()
		SetClipboardText(ply:SteamID64())
	end)
	sid:AddOption("Profile Link", function()
		SetClipboardText("https://steamcommunity.com/profiles/" .. ply:SteamID64())
	end)
	return true
end

function GM:TTTRWGetPlayerCategory(ply)
	if (ply:Team() == TEAM_CONNECTING) then
		return "Connecting"
	end
	if (ply:Team() == TEAM_SPECTATOR) then
		return "Spectators"
	end

	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE and not ply:Alive()) then
		return "Dead"
	end

	if (IsValid(ply.DeadState) and not ply.DeadState:IsDormant()) then
		return ply.DeadState:GetIdentified() and "Dead" or "Unidentified"
	end
	return "Terrorists"
end