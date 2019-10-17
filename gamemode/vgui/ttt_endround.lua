local PANEL = {}

local font_size = 52
local smol_size = 20

surface.CreateFont("ttt_endround_font_large", {
	font = "Lato",
	size = font_size,
	bold = true,
})

surface.CreateFont("ttt_endround_font_desc", {
	font = "Roboto",
	size = smol_size,
	bold = false,
})

function PANEL:Init()
	self.Winner = self:Add "ttt_curved_panel"
	self.Winner:Dock(TOP)
	self.Winner:SetCurve(4)
	self.Winner:SetColor(Color(0, 0, 0))

	self.WinnerText = self.Winner:Add "DLabel"

	self.WinnerText:Dock(FILL)
	self.WinnerText:SetText "unset"
	self.WinnerText:SetContentAlignment(5)
	self.WinnerText:SetFont "ttt_endround_font_large"
	self.WinnerText:SetTextColor(white_text)

	self.Winner:SetTall(font_size * 1.8)

	self.PlayerText = self:Add "DLabel"
	self.PlayerText:SetText "The following players were part of this team:"
	self.PlayerText:SetFont "ttt_endround_font_desc"
	self.PlayerText:Dock(TOP)
	self.PlayerText:DockMargin(0, 40, 0, 0)
	self.PlayerText:SetContentAlignment(5)

	self.Players = self:Add "ttt_centered_wrap"
	self.Players:SetTextColor(white_text)
	self.Players:Dock(TOP)
	self.Players:SetFont "ttt_endround_font_desc"
	self.Players:DockMargin(0, 5, 0, 0)

	self:SetColor(Color(41, 41, 42))
	self:DockPadding(24, 24, 24, 24)
end

function PANEL:SetWinner(role)
	self.Winner:SetColor(role.Color)
end

function PANEL:PerformLayout(w, h)
end

vgui.Register("ttt_endround_info", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
	self:SetCurve(4)
	self:SetColor(Color(17, 15, 13, 255))
	self.Container = self:Add "ttt_curved_panel"
	self.Container:SetColor(Color(17, 15, 13, 0.75 * 255))
	self.Container:SetCurve(self:GetCurve() / 2)
	self.Container:Dock(FILL)

	local pad = self:GetCurve() / 2
	self:DockPadding(pad, pad, pad, pad)
	self:SetSize(math.min(math.max(640, ScrW() / 2), 800), math.min(math.max(ScrH() / 2, 480), 600))
	self:Center()

	self.Tabs = self.Container:Add "EditablePanel"
	self.Tabs:Dock(TOP)
	self.Tabs:SetTall(smol_size * 2)

	self.Close = self:Add "ttt_close_button"
	self.Close:SetColor(Color(37, 173, 125))

	self.Inner = self.Container:Add "ttt_curved_panel"
	self.Inner:Dock(FILL)
	self.Inner:DockPadding(32, 24, 32, 24)
	self.Inner:SetColor(Color(51, 51, 52))
	self.Inner:SetCurve(4)
	self.Inner:SetCurveTopLeft(false)

	self.Info = self.Inner:Add "ttt_endround_info"
	self.Info:Dock(FILL)
	self.Info:SetCurve(4)

	self.Tab1 = self.Tabs:Add "ttt_curved_panel"
	self.Tab1:SetCurve(4)
	self.Tab1:Dock(LEFT)
	self.Tab1:SetWide(100)
	
	self.Tab1:SetCurveBottomLeft(false)
	self.Tab1:SetCurveBottomRight(false)
	self.Tab1:SetColor(self.Inner:GetColor())

	self.Tab1Text = self.Tab1:Add "DLabel"
	self.Tab1Text:SetFont "ttt_endround_font_desc"
	self.Tab1Text:SetText "Information"
	self.Tab1Text:Dock(FILL)
	self.Tab1Text:SetContentAlignment(5)
	surface.SetFont(self.Tab1Text:GetFont())
	local w = surface.GetTextSize(self.Tab1Text:GetText())
	self.Tab1:SetWide(w + smol_size + 30)

	self.Info:InvalidateParent(true)

	self:MakePopup()
	self:SetKeyboardInputEnabled(false)
end

function PANEL:PerformLayout(w, h)
	self.Close:SetSize(32, 32)
	self.Close:SetPos(w - self.Close:GetWide() * 1.5, self.Close:GetWide() * 0.5)

	local pad = self.Close:GetWide()

	self.Container:DockPadding(pad, pad * 0.75, pad, pad)
end

function PANEL:SetWinner(role, players)
	local team = ttt.teams[role]
	self.Info.Winner:SetColor(team.Color)
	self.Info.WinnerText:SetText("The " .. team.Name:gsub("^.", string.upper) .. "s win!")

	self.Info.Players:SetText(table.concat(players, ", "))
end

vgui.Register("ttt_endround", PANEL, "ttt_curved_panel_outline")

net.Receive("ttt_endround", function()
	local winning_team = net.ReadString()

	local names = {}
	for i = 1, net.ReadUInt(8) do
		names[i] = net.ReadString()
	end

	if (IsValid(pluto.endround)) then
		pluto.endround:Remove()
	end
	pluto.endround = vgui.Create "ttt_endround"
	pluto.endround:SetWinner(winning_team, names)
end)

function GM:TTTBeginRound()
	if (IsValid(pluto.endround)) then
		pluto.endround:Remove()
	end
end