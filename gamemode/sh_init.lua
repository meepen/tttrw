GM.Name    = "Trouble in Terrorist Town Rewrite"
GM.Author  = "Meepen <https://steamcommunity.com/id/meepen>"
GM.Email   = "meepdarknessmeep@gmail.com"
GM.Website = "https://github.com/meepen"

DeriveGamemode "base"

ttt = ttt or GM or {}

PLAYER = FindMetaTable "Player"
ENTITY = FindMetaTable "Entity"

function printf(...)
	print(string.format(...))
end

function warn(...)
	MsgC(Color(240,20,20), string.format(...))
end

function GM:InitPostEntity()
	self:InitPostEntity_Networking()
	if (SERVER) then
		self:SetupTextFileEntities()
	end
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
end

function GM:StartCommand(ply, cmd)
	player_manager.RunClass(ply, "StartCommand", cmd)
end

function GM:ScalePlayerDamage(ply, hitgroup, dmg)
	local wep = dmg:GetInflictor()
	if (IsValid(wep) and wep.ScaleDamage) then
		wep:ScaleDamage(hitgroup, dmg)
	end
end

function GM:KeyPress(ply, key)
	self:VoiceKey(ply, key)

	if (key == IN_USE and self:TryInspectBody(ply)) then
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