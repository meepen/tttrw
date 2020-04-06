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
	self:SetCurve(4)
	self:Dock(TOP)
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

function PANEL:SetWinner(role, players)
	local team = ttt.teams[role]
	self.Winner:SetColor(team.Color)
	self.WinnerText:SetText("The " .. team.Name:gsub("^.", string.upper) .. "s win!")

	self.Players:SetText(table.concat(players, ", "))
end

vgui.Register("ttt_endround_info", PANEL, "ttt_curved_panel")

--- ttt.endroundinfo

net.Receive("ttt_endround", function()
	local winning_team = net.ReadString()

	local names = {}
	for i = 1, net.ReadUInt(8) do
		names[i] = net.ReadString()
	end

	ttt.endroundinfo = {
		Winners = winning_team,
		Names = names
	}

	hook.Run "ShowEndRoundScreen"
end)

function GM:ShowEndRoundScreen()
	if (not ttt.endroundinfo) then
		return false
	end

	if (IsValid(ttt.endround)) then
		ttt.endround:Remove()
		return true
	end

	ttt.endround = vgui.Create "tttrw_base"
	local info = vgui.Create "ttt_endround_info"
	info:SetWinner(ttt.endroundinfo.Winners, ttt.endroundinfo.Names)
	info:SetTall(310)
	ttt.endround:AddTab("Info", info)

	ttt.endround:SetSize(640, 400)
	ttt.endround:Center()
	ttt.endround:MakePopup()
	ttt.endround:SetKeyboardInputEnabled(false)
	return true
end

function GM:TTTBeginRound()
	ttt.endroundinfo = nil
	if (IsValid(ttt.endround)) then
		ttt.endround:Remove()
	end

	self:EquipmentReset()

	if (SERVER) then
		self:SV_TTTBeginRound()
	end
end