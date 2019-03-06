resource.AddSingleFile "resource/fonts/Lato-Regular.ttf"
resource.AddSingleFile "resource/fonts/Lato-Semibold.ttf"


AddCSLuaFile "sh_init.lua"
AddCSLuaFile "cl_hud_helpers.lua"
AddCSLuaFile "cl_hud.lua"
AddCSLuaFile "cl_scoreboard.lua"


include "sh_init.lua"

include "sv_player_management.lua"
include "sv_round_system.lua"
include "sv_spawning.lua"
include "sv_spectator.lua"
include "sv_ragdoll.lua"