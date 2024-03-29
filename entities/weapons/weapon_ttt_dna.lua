AddCSLuaFile()
SWEP.HoldType           = "normal"
SWEP.PrintName          = "DNA Scanner"
SWEP.Slot               = 8

SWEP.ViewModelFlip      = false
SWEP.ViewModelFOV       = -100

SWEP.Primary.Automatic     = false
SWEP.Primary.Ammo          = "none"
SWEP.Primary.ClipSize      = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Delay		   = .4

SWEP.Secondary.Delay 		= 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.AutoSpawnable         = false
SWEP.Spawnable             = true

SWEP.InLoadout = {
	Detective = true
}

SWEP.ViewModel             = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel            = "models/props_lab/huladoll.mdl"

SWEP.Base                  = "weapon_tttbase"
DEFINE_BASECLASS "weapon_tttbase"

function SWEP:CanPrimaryAttack()
	if (ttt.GetRoundState() ~= ttt.ROUNDSTATE_ACTIVE) then
		return false
	end

	return true
end

local invalid_vector = Vector(0/0)

assert(invalid_vector.x ~= invalid_vector.x, "Vector equality changed")

function SWEP:SetupDataTables()
	BaseClass.SetupDataTables(self)
	self:NetVar("DNAPosition", "Vector", invalid_vector)
	self:NetVar("CurrentDNA", "Entity")
	self:NetVar("NextScan", "Float", -math.huge)
end


function SWEP:Initialize()
	BaseClass.Initialize(self)
	if (CLIENT) then
		hook.Add("HUDPaint", self, self.HUDPaint)
	else
		hook.Add("PlayerTick", self, self.PlayerTick)
	end
end

function SWEP:PrimaryAttack()
	if (not self:CanPrimaryAttack() or not SERVER) then
		return
	end
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	self:GetOwner():LagCompensation(true)
	local tr = self:GetOwner():GetEyeTrace()
	self:GetOwner():LagCompensation(false)

	local ent = tr.Entity

	if (not IsValid(ent)) then
		return
	end

	if (tr.HitPos:Distance(self:EyePos()) > 85) then
		self:GetOwner():Notify "You are too far away from the object"
		return
	end

	if (tr.Entity:GetNW2Bool("IsPlayerBody", false) and not tr.Entity.HiddenState:GetIdentified()) then
		self:GetOwner():Notify "You must identify the body!"
		return
	end

	local already_got = {}

	for _, ent in pairs(self:GetChildren()) do
		if (ent.IsDNA and IsValid(ent:GetOldDNA())) then
			already_got[ent:GetOldDNA()] = true
		end
	end
	
	local had_dna = false
	local got_dna = 0
	local dna
	for _, child in pairs(ent:GetChildren()) do
		if (child.IsDNA) then
			had_dna = true
			if (not already_got[child]) then
				got_dna = got_dna + 1
				dna = gmod.GetGamemode():CreateDNAData(child:GetDNAOwner())
				dna:SetOwner(child:GetParent())
				dna:SetOldDNA(child)
				dna:SetParent(self)
				dna:Spawn()
			end
		end
	end

	if (not had_dna) then
		self:GetOwner():Notify "There are no DNA samples"
	elseif (got_dna > 0) then
		self:GetOwner():Notify("You collected " .. got_dna .. " DNA sample" .. (got_dna == 1 and "" or "s"))
		self:SetCurrentDNA(dna)
		hook.Run("TTTFoundDNA", self:GetOwner(), dna:GetDNAOwner(), ent)
	else
		self:GetOwner():Notify "You already collected the DNA samples off this."
	end
end

function SWEP:SecondaryAttack()
	if (not CLIENT or not self:CanPrimaryAttack() or IsValid(self.Menu)) then
		return
	end

	self.Menu = vgui.Create "ttt_dna_menu"
	self.Menu:SetSize(500, 350)
	self.Menu:SetPos(ScrW() - self.Menu:GetWide(), ScrH() - self.Menu:GetTall())
	self.Menu:MakePopup()
	self.Menu:SetKeyboardInputEnabled(false)
end

function SWEP:DeleteMenu()
	if (CLIENT and IsValid(self.Menu)) then
		self.Menu:Remove()
	end
end

function SWEP:DrawWorldModel()
	if (not IsValid(self:GetOwner())) then
		self:DrawModel()
	end
end

function SWEP:Holster()
	self:DeleteMenu()

	return true
end

function SWEP:OnRemove()
	self:DeleteMenu()
end

function SWEP:Reload()
	if (SERVER) then
		self:SetCurrentDNA(NULL)
	end
end

function SWEP:OwnerChanged()
	self:DeleteMenu()
end

if (SERVER) then
	util.AddNetworkString "weapon_ttt_dna"
	net.Receive("weapon_ttt_dna", function(len, cl)
		local wep = cl:GetWeapon "weapon_ttt_dna"

		if (not IsValid(wep)) then
			return
		end

		local ent = net.ReadEntity()

		for _, child in pairs(wep:GetChildren()) do
			if (ent ~= child) then
				continue
			end
			wep:SetCurrentDNA(wep:GetCurrentDNA() == child and NULL or child)
			return
		end
	end)
	util.AddNetworkString "weapon_ttt_dna_delete"
	net.Receive("weapon_ttt_dna_delete", function(len, cl)
		local wep = cl:GetWeapon "weapon_ttt_dna"

		if (not IsValid(wep)) then
			return
		end

		local ent = net.ReadEntity()

		for _, child in pairs(wep:GetChildren()) do
			if (ent ~= child) then
				continue
			end
			if (wep:GetCurrentDNA() == child) then
				wep:SetCurrentDNA(NULL)
			end
			child:Remove()
			return
		end
	end)

	local Distances = {
		{
			Distance = 250,
			Time = 3
		},
		{
			Distance = 750,
			Time = 5
		},
		{
			Distance = 1200,
			Time = 9
		},
		{
			Distance = 2000,
			Time = 15
		}
	}

	function SWEP:PlayerTick(ply)
		if (self:GetOwner() ~= ply) then
			return
		end

		if (self:GetNextScan() > CurTime() or not IsValid(self:GetCurrentDNA())) then
			return
		end

		local owner = self:GetCurrentDNA():GetDNAOwner()

		if (not IsValid(owner)) then
			return
		end

		local pos = owner:GetPos()

		local dist = pos:Distance(ply:GetPos())

		local time_add = Distances[1].Time
		for i = 1, #Distances - 1 do
			local prev = Distances[i]
			local next = Distances[i + 1]

			if (prev.Distance < dist and next.Distance > dist) then
				time_add = Lerp((dist - prev.Distance) / (next.Distance - prev.Distance), prev.Time, next.Time)
				break
			end
		end

		if (Distances[#Distances].Distance < dist) then
			time_add = Distances[#Distances].Time
		end

		self:SetNextScan(CurTime() + time_add)

		self:SetDNAPosition(pos + VectorRand() * 0.01)
	end

	return
end

local tttrw_dna_beep_sound = CreateConVar("tttrw_dna_beep_sound", "sound/buttons/blip2.wav", FCVAR_ARCHIVE, "Beep sound for DNA")

local indicator = surface.GetTextureID "effects/select_ring"
function SWEP:HUDPaint()
	if (self:GetOwner() ~= LocalPlayer()) then
		return
	end
	-- draw time left for next scan, position of dna

	if (not IsValid(self:GetCurrentDNA())) then
		return
	end

	local pos = self:GetDNAPosition()
	if (pos.x ~= pos.x) then
		return
	end

	if (pos ~= self.LastPosition) then
		sound.PlayFile(tttrw_dna_beep_sound:GetString(), "mono", function(station, eid, err)
			if (IsValid(station)) then
				station:Play()
			else
				warn(err)
			end
		end)
		self.LastPosition = pos
	end

	surface.SetFont "HudSelectionText"

	local col = color_white

	-- Player radar
	surface.SetTexture(indicator)
	
	local scrpos = pos:ToScreen()
	if (IsOffScreen(scrpos)) then return end
	
	surface.SetDrawColor(col)
	surface.SetTextColor(col)

	local sz = 24
	scrpos.x = math.Clamp(scrpos.x, sz, ScrW() - sz)
	scrpos.y = math.Clamp(scrpos.y, sz, ScrH() - sz)

	surface.DrawTexturedRect(scrpos.x - sz, scrpos.y - sz, sz * 2, sz * 2)

	local text = math.ceil(self:GetOwner():GetPos():Distance(pos))
	local w, h = surface.GetTextSize(text)
	-- Show range to target
	surface.SetTextPos(scrpos.x - w / 2, scrpos.y - h / 2)
	surface.DrawText(text)  
end