local ttt_body_normal = Color(51, 51, 52)

surface.CreateFont("ttt_bugs_text_font", {
	font = 'Roboto',
	size = ScrH() / 80,
	weight = 0
})

surface.CreateFont("ttt_bugs_header_font", {
	font = 'Lato',
	size = ScrH() / 20,
	weight = 200
})

DEFINE_BASECLASS "ttt_curved_panel"
local Padding = math.Round(ScrH() * 0.015)

local PANEL = {}

function PANEL:Init()
	self:SetCurve(6)
    self:SetColor(ttt_body_normal)
	self:DockPadding(Padding, Padding, Padding, Padding)

	self.Header = self:Add("DLabel")
	self.Header:SetFont("ttt_bugs_header_font")
	self.Header:Dock(TOP)
	self.Header:SetText("Bugs & Suggestions")
	self.Header:SizeToContents()
	
	self.Checkbox = self:Add "ttt_checkbox_label"
	self.Checkbox:DockMargin(1, Padding, 0, 0)
	self.Checkbox:SetText("Is this a Suggestion?")
	self.Checkbox:SetFont("ttt_bugs_text_font")
	self.Checkbox:SetValue(0)
	self.Checkbox:Dock(TOP)
	surface.SetFont(self.Checkbox.Label:GetFont())
	local _, h = surface.GetTextSize "A"
	self.Checkbox:SetTall(h + Padding / 2)

	self.Title = self:Add("DTextEntry")
	self.Title:Dock(TOP)
	self.Title:SetTall(h + Padding / 2)
	self.Title:DockMargin(0, Padding, 0, 0)
	self.Title:SetPlaceholderText("Short Description")

	self.Contents = self:Add("DTextEntry")
	self.Contents:Dock(FILL)
	self.Contents:DockMargin(0, Padding, 0, Padding)
	self.Contents:SetEnterAllowed(false)
	self.Contents:SetPlaceholderText("Please describe this in more detail here.")
	self.Contents:SetMultiline(true)

	self.Send = self:Add("DButton")
	self.Send:Dock(BOTTOM)
	self.Send:SetText("Submit")
	function self.Send:DoClick()
		net.Start("BugReportSubmit")
			local p = self:GetParent()
			p.Checkbox:SetDisabled(true)
			p.Title:SetDisabled(true)
			p.Contents:SetDisabled(true)
			self:SetDisabled(true)
			net.WriteBool(p.Checkbox:GetChecked())
			net.WriteString(p.Title:GetText())
			net.WriteString(p.Contents:GetText())
			net.WriteUInt(ScrW(), 32)
			net.WriteUInt(ScrH(), 32)
			net.WriteString(jit.os)
			net.WriteString(VERSION)
			net.WriteString(BRANCH)
		net.SendToServer()
		net.Receive("BugReportResponse", function()
			if (net.ReadBool()) then
				self:GetParent():GetParent():Remove()
				chat.AddText("Submitted! We will get to this as soon as we can! Thanks!")
			else
				chat.AddText("Failed! Please let one of the Developers know this happened!")
				
				if (not IsValid(self) or not IsValid(self:GetParent()) then return end
				self:SetDisabled(false)
				
				local p = self:GetParent()
				p.Checkbox:SetDisabled(false)
				p.Title:SetDisabled(false)
				p.Contents:SetDisabled(false)
			end
		end)
	end
end

vgui.Register("ttt_bug_report_body", PANEL, "ttt_curved_panel")

local PANEL = {}

function PANEL:Init()
    self:SetColor(Color(13, 12, 13, 240))
	self:SetCurve(10)
	self:SetSize(ScrW() / 4, ScrH() / 2)
	self:Center()
	self:SetSkin("tttrw")

	self.Close = self:Add("ttt_close_button")
    self.Close:SetZPos(1)
    self.Close:SetColor(Color(37, 173, 125))

	self:DockPadding(Padding, Padding, Padding, Padding)

	self.Inner = self:Add "ttt_bug_report_body"
	self.Inner:Dock(FILL)
end

function PANEL:PerformLayout(w, h)
    self.Close:SetSize(Padding, Padding)
    self.Close:SetPos(w - self.Close:GetWide() - Padding / 2, Padding / 2)
    
    BaseClass.PerformLayout(self, w, h)
end

vgui.Register("ttt_bug_report", PANEL, "ttt_curved_panel")

function GM:ShowTeam()
	local tttbugreports = vgui.Create("ttt_bug_report")
	tttbugreports:MakePopup()
end