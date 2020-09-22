GM.Name    = "Trouble in Terrorist Town Rewrite"
GM.Author  = "Meepen <https://steamcommunity.com/id/meepen>"
GM.Email   = "meepdarknessmeep@gmail.com"
GM.Website = "https://github.com/meepen"

DeriveGamemode "base"
DEFINE_BASECLASS "gamemode_base"

IN_USE_ALT = IN_CANCEL

ttt = ttt or GM or {}

PLAYER = FindMetaTable "Player"

function PLAYER:GetEyeTrace(mask)
	return util.TraceLine {
		start = self:EyePos(),
		endpos = self:EyePos() + self:GetAimVector() * 0xffff,
		mask = mask,
		filter = self,
	}
end

white_text = Color(230, 230, 230, 255)

function PLAYER:IsActive()
	return self:Alive()
end

function PLAYER:IsSpec()
	return not self:IsActive()
end

AccessorFunc(PLAYER, "Target", "Target")
ENTITY = FindMetaTable "Entity"

function PLAYER:SetTarget(target)
	self.Target = target
	hook.Run("PlayerTargetChanged", self, target)
end

function printf(...)
	print(string.format(...))
end

function warn(...)
	MsgC(Color(240,20,20), string.format(...))
	MsgN ""
end

function GM:InitPostEntity()
	self:InitPostEntity_Networking()
	self:GetActiveAmmos()
	if (SERVER) then
		self:SetupTextFileEntities()
	end
end

local function IsAmmo(classname)
    DEFINE_BASECLASS(classname)
    return BaseClass and BaseClass.IsAmmo
end
function GM:GetActiveAmmos()
	if (not self.Ammos) then
		local Ammos = {}
		for ClassName, ent in pairs(scripted_ents.GetList()) do
			
			if (IsAmmo(ClassName)) then
				Ammos[ent.t.AmmoType] = {
					AmmoEnt = ClassName,
					Max = ent.t.AmmoMax
				}
			end
		end
		
		self.Ammos = Ammos
	end

	return self.Ammos
end

function GM:Initialize()
	self:SetupRoles()
	if (SERVER) then
		self:SetupTTTCompatibleEntities()
		self:TrackCurrentCommit()
	end
end

function GM:PlayerTick(ply)
	player_manager.RunClass(ply, "Think")
	if (SERVER) then
		self:Drown(ply)

		if (ply.propspec) then
			self:SpectatePropRecharge(ply)
		end
	end
end

function GM:StartCommand(ply, cmd)
	if (SERVER and cmd.SetTickCount and VERSION <= 190730) then -- server is always one tick ahead for some reason :(
		cmd:SetTickCount(cmd:TickCount() - 1)
	end
	-- fixes some hitreg issues
	-- causes issues with props!
	-- ply:SetAngles(Angle(0, cmd:GetViewAngles().y))

	local wep = ply:GetActiveWeapon()
	if (IsValid(wep) and wep.OverrideCommand) then
		wep:OverrideCommand(ply, cmd)
	end

	if (cmd:KeyDown(IN_USE)) then
		cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_USE_ALT))
	end

	if (cmd:KeyDown(IN_ZOOM)) then
		cmd:SetButtons(bit.bor(bit.band(bit.bnot(IN_ZOOM), cmd:GetButtons()), IN_GRENADE2))
	end

	player_manager.RunClass(ply, "StartCommand", cmd)
end

function GM:ScalePlayerDamage(ply, hitgroup, dmg)
	local wep = dmg:GetInflictor()
	if (IsValid(wep) and wep.ScaleDamage) then
		wep:ScaleDamage(hitgroup, dmg)
	end
	if (SERVER) then
		self:Karma_ScalePlayerDamage(ply, hitgroup, dmg)
	end
end

function GM:KeyPress(ply, key)
	if (key == IN_GRENADE2 and CLIENT and IsFirstTimePredicted()) then
		RunConsoleCommand "ttt_radio"
	end

	if (self.VoiceKey) then
		self:VoiceKey(ply, key)
	end

	if (CLIENT and key == IN_USE_ALT and not IsValid(ttt.InspectMenu) and self:TryInspectBody(ply)) then
		return
	end

	if (key == IN_WEAPON1) then
		self:DropCurrentWeapon(ply)
	elseif (SERVER) then
		self:SpectatorKey(ply, key)
	end
end

TEAM_TERROR = 1
function GM:CreateTeams()
	team.SetUp(TEAM_TERROR, "Terrorist", Color(46, 192, 94), false)
end

-- do this here so we can format stuff clientside to predict it ourselves
function GM:FormatPlayerText(ply, text, team)
	local replacements = {}
	local capitalize = {}

	if (IsValid(ply.Target)) then
		if (ply.Target:IsPlayer()) then
			replacements["{target}"] = ply.Target:Nick()
		elseif (IsValid(ply.Target.HiddenState) and ply.Target.HiddenState:GetIdentified()) then
			replacements["{target}"] = ply.Target.HiddenState:GetNick() .. "'s body"
		else
			replacements["{target}"] = "an unidentified body"
			capitalize["{target}"] = true
		end
	else
		replacements["{target}"] = "nobody"
		capitalize["{target}"] = true
	end
	
	capitalize["{lookingat}"] = capitalize["{target}"]
	replacements["{lookingat}"] = replacements["{target}"]

	local amount = 0

	return text:gsub("()({.+})", function(ind, what)
		local replace = replacements[what]

		if (ind == 1 and capitalize[what] and replace) then
			replace = replace:sub(1, 1):upper() .. replace:sub(2)
			amount = amount + 1
		end

		return replace
	end), amount
end