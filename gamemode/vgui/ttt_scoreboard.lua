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
end

vgui.Register("tttrw_scoreboard_header_logo", PANEL, "DLabel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(6)
	self:SetTall(110)
	self:SetColor(outline)

	local pnl = hook.Run "TTTGetScoreboardLogoPanel"
	self.Logo = self:Add(pnl)
	if (not IsValid(self.Logo)) then
		ErrorNoHalt("Couldn't create Logo Panel: " .. pnl)
		self.Logo = self:Add "tttrw_scoreboard_header_logo"
	end
	self.Logo:Dock(LEFT)
	self.Logo:SizeToContents()

	self:SetTall(self.Logo:GetTall() + Padding * 2)

	self.RoundNumber = self:Add "DLabel"
	self.RoundNumber:Dock(RIGHT)
	self.RoundNumber:SetContentAlignment(3)
	self.RoundNumber:SetFont "ttt_scoreboard_rank"

	self:DockPadding(Padding, Padding, Padding, Padding)
end

function PANEL:Think()
	self.RoundNumber:SetText(string.format("Round %i", ttt.GetRoundNumber()))
	self.RoundNumber:SizeToContents()
end

function PANEL:DrawInner(w, h)
	local curve = self:GetCurve() / 2
	surface.SetDrawColor(main_color)
	surface.DrawRect(curve, curve, w - curve * 2, h - curve * 2)
end

vgui.Register("tttrw_scoreboard_header", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self.Text = self:Add "DLabel"
	self.Text:SetContentAlignment(5)
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

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:SizeToContents()
	self.Text:SizeToContents()
	local w, h = self.Text:GetSize()

	self:SetSize(w + Padding * 2, h + 4)

	self.Text:Center()
end

function PANEL:SetColor(col)
	self.InnerColor = col
end

DEFINE_BASECLASS "ttt_curved_panel_outline"

function PANEL:Paint(w, h)
	surface.SetDrawColor(self.InnerColor or white_text)
	local curve = self:GetCurve() / 2
	surface.DrawRect(curve, curve, w - curve * 2, h - curve * 2)
	BaseClass.Paint(self, w, h)
end

vgui.Register("ttt_scoreboard_rank", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self:SetText("")

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

	self:SetWide(max_w + Padding * 2 + Slant * 2)
end

function PANEL:SetStatus(stat)
	if (stat == self.Status) then stat = ttt.STATUS_DEFAULT end
	self.Status = stat
	self:SetColor(ttt.Status[self.Status]["color"])
	self.Text:SetText(ttt.Status[self.Status]["text"])

	if (IsValid(self:GetParent().Player)) then
		ttt.SetPlayerStatus(self:GetParent().Player, stat)
		self:GetParent():GetParent():Toggle()
	end
end

function PANEL:SetColor(col)
	self.Color = col
end

function PANEL:DoClick()
	self:GetParent():DoClick()
end

function PANEL:Paint(w, h)
	if (not self.Rect) then return end
	surface.SetDrawColor(self.Color)
	draw.NoTexture()
	surface.DrawPoly(self.Rect)
end

function PANEL:PerformLayout(w, h)
	self.Rect = {
		{x = Slant * (h / (h + Padding)), y = 0},
		{x = w, y = 0},
		{x = w - Slant * (h / (h + Padding)), y = h},
		{x = 0, y = h}
	}
end

vgui.Register("ttt_scoreboard_status", PANEL, "ttt_curved_button")

local PANEL = {}
DEFINE_BASECLASS "ttt_curved_panel"

function PANEL:Init()
	self:SetCurve(math.Round(Padding / 2))
	--self:SetColor(Color(70, 102, 135, 0.8 * 255))

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

function PANEL:Scissor()
    local x0, y0, x1, y1 = self:GetRenderBounds()
    render.SetScissorRect(x0, y0, x1, y1, true)
end

function PANEL:Paint(w, h)

	if (not IsValid(self.Player)) then
		self:SetColor(Color(17, 15, 13, 0.75 * 255))
		BaseClass.Paint(self, w, h)
		return
	end

	if (not self.Rect1) then return end

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

		draw.NoTexture()

		surface.SetDrawColor(self.Player:GetRoleData().Color)
		surface.DrawPoly(self.Rect1)

		surface.SetDrawColor(17, 15, 13, 0.75 * 255)
		surface.DrawPoly(self.Rect2)

		hud.EndStenciledMesh()
	else
		self.Mesh:Draw()
	end
	render.SetScissorRect(0, 0, 0, 0, false)
end

function PANEL:PerformLayout(w, h)
	self.Rect1 = {
		{x = 0, y = 0},
		{x = w * 0.4, y = 0},
		{x = w * 0.4 - Slant, y = h},
		{x = 0, y = h}
	}

	self.Rect2 = {
		{x = w * 0.4 + Padding, y = 0},
		{x = w, y = 0},
		{x = w, y = h},
		{x = w * 0.4 - Slant + Padding, y = h},
	}

	
	self.RankContainer:SetWide(w * 0.4 - Slant * 2 - self.Name:GetWide())

	if (IsValid(self.Status)) then 
		self.Status:SetPos(w*.4-Slant+Padding*3, Padding/2)
	end
end

function PANEL:Think()
	local ply = self.Player
	if (IsValid(ply)) then
		local group = "Terrorists"

		if (ply:Team() == TEAM_CONNECTING or ply:Team() == TEAM_SPECTATOR) then
			group = "Spectators"
		elseif (not ply:Alive() and IsValid(ply.DeadState) and (ply.DeadState:GetIdentified() or ply:GetConfirmed())) then
			group = "Dead"


		elseif (not ply:Alive() and (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE or not LocalPlayer():Alive() or LocalPlayer():GetRoleData().Evil) or IsValid(ply.DeadState)) then
			group = "Unidentified"
		end

		if (self.Group ~= group) then
			if (group == "Unidentified" and not ttt.Scoreboard.Inner.Groups["Unidentified"]) then
				ttt.Scoreboard.Inner:AddGroup("Unidentified", Color(85, 111, 87), {})
			end

			if (group ~= "Terrorists" and ply ~= LocalPlayer()) then
				self.Status:SetStatus(ttt.STATUS_DEAD)
				self:GetParent():Disable()
			end
			
			self:GetParent():SetParent(ttt.Scoreboard.Inner.Groups[group])
			self.Group = group
		end

		self.Karma:SetText(ply:GetKarma())
	end
end

function PANEL:SetPlayer(ply, group)
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

vgui.Register("ttt_scoreboard_player_render", PANEL, "ttt_curved_button")

local PANEL = {}

function PANEL:Init()
	self.Statuses = {}
	self:DockPadding(0, 0, Padding * Padding, 0)
	self:DockMargin(0, -Padding/4, 0, 0)
	
	for STATUS = ttt.STATUS_MISSING, ttt.STATUS_KOS do
		self.Statuses[STATUS] = self:Add "ttt_scoreboard_status"
		self.Statuses[STATUS]:SetStatus(STATUS)
		self.Statuses[STATUS]:SizeToContentsX()
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
	self:Dock(TOP)

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
end

function PANEL:Paint() end

vgui.Register("ttt_scoreboard_player", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self.Render = self:Add "ttt_scoreboard_group_header_render"
	self.Render:Dock(LEFT)
	self:Dock(TOP)
end

function PANEL:SetColor(col)
	--self.Render:SetColor(col)
	self.Render:SetColor(ColorAlpha(dark, 240))
end

function PANEL:SetText(text)
	self.Render:SetText(text)
	self:SetTall(self.Render:GetTall() * 1.8)
end

vgui.Register("ttt_scoreboard_group_header", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(4)
	self.Color = outline

	self:DockPadding(0, Padding / 2, 0, Padding / 2)

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
	self:SetWide(self:GetParent():GetWide())

	self.Text:Center()
end

function PANEL:SetColor(c)
	self.InnerColor = c
end

function PANEL:DrawInner(w, h)
	local curve = self:GetCurve() / 2
	surface.SetDrawColor(self.InnerColor or main_color)
	surface.DrawRect(curve, curve, w - curve * 2, h - curve * 2)
end

vgui.Register("ttt_scoreboard_group_header_render", PANEL, "ttt_curved_panel_outline")

local PANEL = {}

function PANEL:Init()
	self.Players = {}
	self:Dock(TOP)
	self:DockMargin(0, 0, 0, Padding)

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
		pnl:SetPlayer(v, self.Header:GetText())
		pnl:SetZPos(v:UserID())
		self.Players[i] = pnl
	end
end

function PANEL:SetText(text)
	self.Header:SetText(text)
	self:SetTall(self.Header:GetTall())
end

function PANEL:OnChildAdded()
	self:InvalidateLayout(true)
end
function PANEL:OnChildRemoved()
	self:InvalidateLayout(true)
end

function PANEL:PerformLayout()
	self:SetSize(self:ChildrenSize())
end

vgui.Register("ttt_scoreboard_group", PANEL, "EditablePanel")

local PANEL = {}

function PANEL:Init()
	self:SetColor(outline)
	self:SetCurve(6)

	self:SetWide(ScrW() - ScrW() / 3)

	self:DockPadding(Padding * 2, Padding * 2, Padding * 2, Padding * 2)

	self.Contents = {}

	self.Groups = {}

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

	self:AddGroup("Terrorists", Color(14, 88, 34), living)
	--if (LocalPlayer():GetRoleData().Evil or not LocalPlayer():Alive() or ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
	if #unidentified > 0 then
		self:AddGroup("Unidentified", Color(85, 111, 87), unidentified)
	end
	self:AddGroup("Dead", Color(80, 105, 38), dead)
	self:AddGroup("Spectators", Color(127, 129, 13), spectators)
	--self:AddGroup("Connecting", Color(255, 255, 255), connecting)
	self:InvalidateLayout()

	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)
end

function PANEL:AddGroup(name, color, plys)
	local pnl = self.Scroller:Add "ttt_scoreboard_group"
	self.Groups[name] = pnl

	pnl:SetColor(color)
	pnl:SetText(name)
	pnl:SetPlayers(plys)
	pnl:Dock(TOP)

	table.insert(self.Contents, pnl)
end

function PANEL:DrawInner(w, h)
	local curve = self:GetCurve() / 2
	surface.SetDrawColor(main_color)
	surface.DrawRect(curve, curve, w - curve * 2, h - curve * 2)
end

vgui.Register("ttt_scoreboard_inner", PANEL, "ttt_curved_panel_outline")


local PANEL = {}

function PANEL:Init()
	self.Header = self:Add "tttrw_scoreboard_header"
	self.Header:Dock(TOP)
	--self.Header:SetTall(150)
	self.Header:DockMargin(0, 0, 0, 4)
	self.Header:SetCurveBottomLeft(false)
	self.Header:SetCurveBottomRight(false)
	
	self.Inner = self:Add "ttt_scoreboard_inner"
	self.Inner:Dock(FILL)
	self.Inner:SetCurveTopLeft(false)
	self.Inner:SetCurveTopRight(false)
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