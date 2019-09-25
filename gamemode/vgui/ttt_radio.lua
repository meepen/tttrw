local PANEL = {}
local lifetime = 8
local color = Color(0xb, 0xc, 0xb, 220)
local alpha_low = 0
local alpha_high = 220
AccessorFunc(PANEL, "ActiveTime", "ActiveTime")

surface.CreateFont("ttt_radio_menu_font", {
	font = 'Lato',
	size = ScrH() / 70,
	weight = 200
})

DEFINE_BASECLASS "ttt_curved_panel"
function PANEL:Init()
	self:SetCurve(7)
	self:SetColor(color)
	self:SetCurveTopLeft(false)
	self:SetCurveBottomLeft(false)

	self:Format()

	hook.Add("PlayerBindPress", self, self.PlayerBindPress)
	hook.Add("PlayerTargetChanged", self, self.Format)
end

function PANEL:Format()
	local w = -math.huge

	local num = 1
	surface.SetFont "ttt_radio_menu_font"
	for _, ind in ipairs(ttt.QuickChat_Order) do
		local pnl = self:Find(ind)
		if (not IsValid(pnl)) then
			pnl = self:Add "DLabel"
			pnl:SetName(ind)
		end
		pnl:SetFont "ttt_radio_menu_font"
		pnl:Dock(TOP)
		pnl:SetText(num .. " - " .. hook.Run("FormatPlayerText", LocalPlayer(), ttt.QuickChat[ind]) or ttt.QuickChat[ind])
		w = math.max(surface.GetTextSize(pnl:GetText()) + 10, w)
		pnl:SizeToContentsY(5)
		pnl:SetZPos(num)
		pnl:SetContentAlignment(7)
		pnl:DockMargin(5, 0, 0, 0)
		pnl.id = ind
		num = num + 1
	end

	self:DockPadding(0, 5, 0, 0)
	self:SetWide(w)
	self:InvalidateLayout(true)
	self:SizeToContentsY(0)
end

function PANEL:PlayerBindPress(ply, bind, pressed)
	if (bind:match"^slot%d+$") then
		local num = tonumber(bind:match"^slot(%d+)$")
		for _, child in ipairs(self:GetChildren()) do
			if (child:GetZPos() == num) then
				if (not pressed) then
					RunConsoleCommand("ttt_radio", child.id)
					self:Remove()
				end
				return true
			end
		end
	end
end

function PANEL:GetContentSize()
	local _w, _h = self:GetSize()

	for _, child in pairs(self:GetChildren()) do
		local x, y = child:GetPos()
		x = x + child:GetWide()
		y = y + child:GetTall()
		if (y > _h) then
			_h = y
		end
		if (x > _w) then
			_w = x
		end
	end

	return _w, _h
end

function PANEL:PerformLayout()
	self:SetPos(0, ScrH() / 2 - self:GetTall() / 2)
end

function PANEL:Paint(w, h)
	local frac = (CurTime() - self:GetActiveTime()) / lifetime
	local alpha = alpha_high
	if (frac > 0.5) then
		alpha = Lerp((frac - 0.5) * 2, alpha_high, alpha_low)
	end
	self:SetColor(ColorAlpha(color, alpha))

	for _, child in pairs(self:GetChildren()) do
		child:SetColor(ColorAlpha(child:GetColor(), alpha))
	end
	BaseClass.Paint(self, w, h)
end

function PANEL:Think()
	if (self:GetActiveTime() + lifetime < CurTime()) then
		self:Remove()
	end
end

vgui.Register("ttt_radio_menu", PANEL, "ttt_curved_panel")