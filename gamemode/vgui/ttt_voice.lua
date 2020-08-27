local PANEL = {}
local PlayerVoicePanels = {}

function PANEL:Init()
	self.LabelName = self:Add "DLabel"
	self.LabelName:SetFont "GModNotify"
	self.LabelName:Dock(FILL)
	self.LabelName:DockMargin(8, 0, 0, 0)
	self.LabelName:SetTextColor(white_text)

	self.Avatar = self:Add "AvatarImage"
	self.Avatar:Dock(LEFT)
	self.Avatar:SetSize(32, 32)

	self.Color = color_transparent

	self:SetSize(250, 32 + 8)
	self:DockPadding(4, 4, 4, 4)
	self:DockMargin(2, 2, 2, 2)
	self:Dock(TOP)
end

function PANEL:Setup(ply)
	self.ply = ply
	self.LabelName:SetText(ply:Nick())
	self.Avatar:SetPlayer(ply)

	self.Color = team.GetColor(ply:Team())

	self:InvalidateLayout()
end

function PANEL:Paint( w, h )
	if (not IsValid(self.ply)) then
		return
	end

	local col
	if (IsValid(self.ply.HiddenState) and not self.ply.HiddenState:IsDormant() and self.ply.VoiceState and self.ply:GetRole() ~= "Innocent") then
		col = self.ply:GetRoleData().Color
	elseif (not self.ply:Alive()) then
		col = Color(self.ply:VoiceVolume() * 255, self.ply:VoiceVolume() * 255, 0, 240)
	else
		col = Color(0, self.ply:VoiceVolume() * 255, 0, 240)
	end

	draw.RoundedBox(4, 0, 0, w, h, col)
end

function PANEL:Think()
	if (IsValid(self.ply)) then
		self.LabelName:SetText(self.ply:Nick())
	end

	if (self.fadeAnim) then
		self.fadeAnim:Run()
	end
end

function PANEL:FadeOut( anim, delta, data )
	if (anim.Finished) then

		if (IsValid(PlayerVoicePanels[self.ply])) then
			PlayerVoicePanels[self.ply]:Remove()
			PlayerVoicePanels[self.ply] = nil
			return
		end

		return
	end
	self:SetAlpha(255 - (255 * delta))
end

derma.DefineControl("VoiceNotify", "", PANEL, "EditablePanel")

function GM:PlayerStartVoice(ply)
	if (not IsValid(ttt.voices)) then return end

	-- There'd be an extra one if voice_loopback is on, so remove it.
	GAMEMODE:PlayerEndVoice(ply)

	if (IsValid(PlayerVoicePanels[ply])) then
		if (PlayerVoicePanels[ply].fadeAnim) then
			PlayerVoicePanels[ply].fadeAnim:Stop()
			PlayerVoicePanels[ply].fadeAnim = nil
		end

		PlayerVoicePanels[ply]:SetAlpha(255)

		return
	end

	if (not IsValid(ply)) then
		return
	end

	local pnl = ttt.voices:Add "VoiceNotify"
	pnl:Setup(ply)
	
	PlayerVoicePanels[ply] = pnl
end

function GM:PlayerEndVoice(ply)
	if (IsValid(PlayerVoicePanels[ply])) then
		if (PlayerVoicePanels[ply].fadeAnim) then return end
		PlayerVoicePanels[ply].fadeAnim = Derma_Anim("FadeOut", PlayerVoicePanels[ply], PlayerVoicePanels[ply].FadeOut)
		PlayerVoicePanels[ply].fadeAnim:Start(2)
	end
end

local function VoiceClean()
	for k, v in pairs(PlayerVoicePanels) do
		if (not IsValid(k)) then
			GAMEMODE:PlayerEndVoice(k)
		end
	end
end
timer.Create("VoiceClean", 10, 0, VoiceClean)

if (IsValid(ttt.voices)) then
	ttt.voices:Remove()
end
ttt.voices = GetHUDPanel():Add "EditablePanel"
ttt.voices:Dock(LEFT)
ttt.voices:SetWide(250)
GetHUDPanel():DockPadding(25, 25, 0, 0)

net.Receive("ttt_voice", function()
	local voice = net.ReadBool()
	local ent = net.ReadEntity()

	ent.VoiceState = voice
end)