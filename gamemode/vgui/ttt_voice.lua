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

	self.VolumeHistory = {}
end

function PANEL:Setup(ply)
	self.ply = ply
	self.LabelName:SetText(ply:Nick())
	self.Avatar:SetPlayer(ply)

	self.Color = team.GetColor(ply:Team())

	self:InvalidateLayout()
end

local function LerpColors(frac, ...)
	local amt = select("#", ...) - 1
	frac = math.min(frac, 0.99999)

	local fromn = math.floor(frac / (1 / amt)) + 1

	local from, to = select(fromn, ...)

	frac = (frac - (fromn - 1) * (1 / amt)) / (1 / amt)

	return Color(
		from.r + (to.r - from.r) * frac,
		from.g + (to.g - from.g) * frac,
		from.b + (to.b - from.b) * frac,
		from.a + (to.a - from.a) * frac
	)
end

local max_volume = Color(255, 50, 0, 100)
local min_volume = Color(0, 255, 0, 100)
local med_volume = Color(255, 255, 0, 100)


function PANEL:Paint( w, h )
	if (not IsValid(self.ply)) then
		return
	end

	local history_length = 4 -- seconds
	table.insert(self.VolumeHistory, {
		Time = CurTime(),
		Volume = self.ply:VoiceVolume()
	})
	self.VolumeHistory.MaxVolume = math.max(self.VolumeHistory.MaxVolume or 0.5, self.ply:VoiceVolume())
	while (self.VolumeHistory[1].Time < CurTime() - history_length) do
		table.remove(self.VolumeHistory, 1)
	end

	local col
	if (IsValid(self.ply.HiddenState) and not self.ply.HiddenState:IsDormant() and (self.ply.VoiceState or not self.ply:GetRoleData().Evil) and self.ply:GetRole() ~= "Innocent") then
		col = ColorAlpha(self.ply:GetRoleData().Color, 210)
	elseif (LocalPlayer():Alive() or self.ply:Alive()) then
		col = Color(23, 25, 21, 240)
	else
		col = Color(100, 120, 0, 240)
	end

	draw.RoundedBox(4, 0, 0, w, h, col)

	local max = self.VolumeHistory.MaxVolume
	for _, data in ipairs(self.VolumeHistory) do
		local frac = 1 - (CurTime() - data.Time) / history_length
		surface.SetDrawColor(LerpColors(data.Volume / max, min_volume, med_volume, max_volume))
		surface.DrawLine(w * frac, h, w * frac, h - h * data.Volume / max)
	end
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
		self.VolumeHistory = {}

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