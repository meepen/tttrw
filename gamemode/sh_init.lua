GM.Name    = "Trouble in Terrorist Town Rewrite"
GM.Author  = "Meepen <https://steamcommunity.com/id/meepen>"
GM.Email   = "meepdarknessmeep@gmail.com"
GM.Website = "https://github.com/meepen"

DeriveGamemode "base"

ttt = ttt or GM or {}

PLAYER = FindMetaTable "Player"

for _, file in ipairs {
	"libraries/quaternion.lua",
	"player_terror.lua",
	"sh_roles.lua",
	"sh_proper_networking.lua",
	"sh_round_system.lua",
	"sh_spectator.lua"
} do
	if (SERVER) then
		AddCSLuaFile(file)
	end
	include(file)
end

function printf(...)
	print(string.format(...))
end

function warn(...)
	MsgC(Color(240,20,20), string.format(...))
end

function GM:InitPostEntity()
	self:InitPostEntity_Networking()
end

function GM:Initialize()
	self:SetupRoles()
end

function GM:PlayerTick(ply)
	player_manager.RunClass(ply, "Think")
end

function GM:StartCommand(ply, cmd)
	player_manager.RunClass(ply, "StartCommand", cmd)
end