-- Converted from default Newton Launcher by add___123
AddCSLuaFile()

DEFINE_BASECLASS "weapon_tttbase"

SWEP.HoldType               = "physgun"

SWEP.PrintName              = "Newton Launcher"
SWEP.Slot                   = 6

SWEP.ViewModelFlip          = false
SWEP.ViewModelFOV           = 54
SWEP.DrawCrosshair          = false

SWEP.Base                   = "weapon_tttbase"

SWEP.ViewModel              = "models/weapons/c_superphyscannon.mdl"
SWEP.WorldModel             = "models/weapons/w_physics.mdl"

SWEP.Primary.Ammo           = "none"
SWEP.Primary.Damage         = 3
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Delay          = 1.5
SWEP.Primary.Cone           = 0.005
SWEP.Primary.Sound          = Sound "weapons/ar2/fire1.wav"
SWEP.Primary.SoundLevel     = 54

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

SWEP.NoSights               = true

SWEP.Kind                   = WEAPON_EQUIP
SWEP.WeaponID               = AMMO_PUSH

SWEP.UseHands               = true

SWEP.Ironsights = false

SWEP.Equipment = {
	Name    = "Newton Launcher",
	Desc 	= "Push with left click, pull with right click.",
	CanBuy	= { traitor = true },
	Cost 	= 1,
	Icon    = "materials/tttrw/equipment/push.png"
}

SWEP.DeploySpeed            = 2.5

SWEP.PushCharging           = false
SWEP.PullCharging           = false

local CHARGE_AMOUNT         = 0.01
local CHARGE_DELAY          = 0.03

function SWEP:Initialize()
    BaseClass.Initialize(self)

    self.NextCharge = 0
    self:SetSkin(1)
end

function SWEP:NetVar(...)
    BaseClass.NetVar(self, ...)
end

function SWEP:SetupDataTables()
    BaseClass.SetupDataTables(self)

    self:NetVar("PushCharge", "Float", 0)
    self:NetVar("PullCharge", "Float", 0)
end

function SWEP:PrimaryAttack()
    if (self.PushCharging or self.PullCharging) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

    self.PushCharging = true
end

function SWEP:SecondaryAttack()
    if (self.PushCharing or self.PullCharging) then return end

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

    self.PullCharging = true
end

function SWEP:FirePulse(force_fwd, force_up, pull)
    local owner = self:GetOwner()
    if (not IsValid(owner)) then return end

    owner:SetAnimation(PLAYER_ATTACK1)

    sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)

    self:SendWeaponAnim(ACT_VM_IDLE)

    local cone = self.Primary.Cone or 0.1
    local num = 6

    local bullet = {}
    bullet.Num    = num
    bullet.Src    = owner:GetShootPos()
    bullet.Dir    = owner:GetAimVector()
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 1
    bullet.Force  = 0
    bullet.Damage = self.Primary.Damage
    bullet.TracerName = "AirboatGunHeavyTracer"

    local fwd = force_fwd / num
    local up = force_up / num
    bullet.Callback = function(att, tr, dmginfo)
        local ent = tr.Entity
        if (SERVER and IsValid(ent) and not (ent:IsPlayer() and ent:IsFrozen())) then
            local pushvel = tr.Normal * fwd * (pull and -1 or 1)

            pushvel.z = math.max(pushvel.z, up)

            ent:SetGroundEntity(nil)
            ent:SetLocalVelocity(ent:GetVelocity() + pushvel)

            if (ent:IsPlayer()) then
                ent.was_pushed = {
                    att = owner,
                    t = CurTime(),
                    wep = self:GetClass(),
                }
            end
        end
    end

    owner:FireBullets(bullet)
end

local CHARGE_FORCE_FWD_MIN = 200
local CHARGE_FORCE_FWD_MAX = 800
local CHARGE_FORCE_UP_MIN = 100
local CHARGE_FORCE_UP_MAX = 200

function SWEP:ChargedAttack(pull)
    local charge = 0

    if (pull) then
        charge = math.Clamp(self:GetPullCharge(), 0, 1)
        
        self.PullCharging = false
        self:SetPullCharge(0)
    else
        charge = math.Clamp(self:GetPushCharge(), 0, 1)
        
        self.PushCharging = false
        self:SetPushCharge(0)
    end

    local force_fwd = Lerp(charge, CHARGE_FORCE_FWD_MIN, CHARGE_FORCE_FWD_MAX)
    local force_up = Lerp(charge, CHARGE_FORCE_UP_MIN, CHARGE_FORCE_UP_MAX)

    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

    self:FirePulse(force_fwd, force_up, pull)
end

function SWEP:PreDrop(died)
    self.PushCharging = false
    self.PullCharging = false
    self:SetPushCharge(0)
    self:SetPullCharge(0)
end

function SWEP:OnRemove()
    self.PushCharging = false
    self.PullCharging = false
    self:SetPushCharge(0)
    self:SetPullCharge(0)
end

function SWEP:Deploy()
    self.PushCharging = false
    self.PullCharging = false
    self:SetPushCharge(0)
    self:SetPullCharge(0)
    return true
end

function SWEP:Holster()
    return (not self.PushCharging and not self.PullCharging)
end

function SWEP:Think()
    BaseClass.Think(self)

    if (self.PushCharging and self.PullCharging) then
        self.PullCharging = false
        self.SetPullCharge(0)
    end

    local owner = self:GetOwner()

    if (not IsValid(owner)) then
        return 
    end

    if (self.PushCharging) then
        if (not owner:KeyDown(IN_ATTACK)) then
            self:ChargedAttack()
        elseif (SERVER and self:GetPushCharge() < 1 and self.NextCharge < CurTime()) then
            self:SetPushCharge(math.min(1, self:GetPushCharge() + CHARGE_AMOUNT))
            self.NextCharge = CurTime() + CHARGE_DELAY
        end
    elseif (self.PullCharging) then
        if (not owner:KeyDown(IN_ATTACK2)) then
            self:ChargedAttack(true)
        elseif (SERVER and self:GetPullCharge() < 1 and self.NextCharge < CurTime()) then
            self:SetPullCharge(math.min(1, self:GetPullCharge() + CHARGE_AMOUNT))
            self.NextCharge = CurTime() + CHARGE_DELAY
        end
    end
end

if (CLIENT) then
    local _x = ScrW() / 2.0
    local _y = ScrH() / 2.0

    function SWEP:DrawHUD()
        local x = _x
        local y = _y
        local nxt = self:GetNextPrimaryFire()
        local charge = math.max(self:GetPushCharge(), self:GetPullCharge())

        local local_team = LocalPlayer():GetRoleTeam()

        if (local_team == "traitor") then
            surface.SetDrawColor(255, 0, 0, 255)
        else
            surface.SetDrawColor(0, 255, 0, 255)
        end

        local length = 10
        local gap = 5

        surface.DrawLine(x - length, y, x - gap, y)
        surface.DrawLine(x + length, y, x + gap, y)
        surface.DrawLine(x, y - length, x, y - gap)
        surface.DrawLine(x, y + length, x, y + gap)

        if (nxt > CurTime() and charge <= 0) then
            local w = Lerp((nxt - CurTime()) / self.Primary.Delay, 0, 30)

            local bx = x + 30
            surface.DrawLine(bx, y - w, bx, y + w)
            surface.DrawLine(bx + 1, y - w, bx + 1, y + w)

            bx = x - 30
            surface.DrawLine(bx, y - w, bx, y + w) 
            surface.DrawLine(bx - 1, y - w, bx - 1, y + w) 
        end

        if (charge > 0) then
            y = y + (y / 3)

            local w, h = 120, 20

            surface.DrawOutlinedRect(x - w/2, y - h, w, h)

            if (local_team == "traitor") then
                surface.SetDrawColor(255, 0, 0, 155)
            else
                surface.SetDrawColor(0, 255, 0, 155)
            end

            surface.DrawRect(x - w/2, y - h, w * charge, h)

            surface.SetFont("TabLarge")
            surface.SetTextColor(255, 255, 255, 180)
            surface.SetTextPos((x - w / 2) + 3, y - h - 15)
            surface.DrawText("CHARGE")
        end
    end
end