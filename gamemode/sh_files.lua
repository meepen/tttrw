AddCSLuaFile();

({
    Server = {
        "sv_player_management.lua",
        "sv_round_system.lua",
        "sv_spawning.lua",
        "sv_spectator.lua",
        "sv_ragdoll.lua",
        "sv_chat.lua"
    },
    Client = {
        "cl_hud_helpers.lua",
        "cl_hud.lua",
        "cl_scoreboard.lua"
    },
    Shared = {
        "sh_init.lua",
        "libraries/quaternion.lua",
        "player_terror.lua",
        "sh_roles.lua",
        "sh_proper_networking.lua",
        "sh_round_system.lua",
        "sh_spectator.lua",
        "player_terror.lua",
        "sh_movement.lua",
		"sh_equipment.lua"
    },
    Load = function(self)
        for _, file in ipairs(self.Shared) do
            if (SERVER) then
                AddCSLuaFile(file)
            end
            include(file)
        end

        for _, file in ipairs(SERVER and self.Server or self.Client) do
            include (file)
        end

        if (not SERVER) then
            return
        end

        for _, file in ipairs(self.Client) do
            AddCSLuaFile(file)
        end
    end
}):Load()