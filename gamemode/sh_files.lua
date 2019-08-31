AddCSLuaFile();

({
	Server = {
		"sv_player_management.lua",
		"sv_round_system.lua",
		"sv_spawning.lua",
		"sv_spectator.lua",
		"sv_ragdoll.lua",
		"sv_chat.lua",
		"sv_hitmarkers.lua",
		"sv_ttt_compat.lua",
		"sv_weapons.lua",
		"sv_logging.lua",
		"sv_mapvote.lua",
	},
	Client = {
		"cl_hud_helpers.lua",
		"vgui/ttt_curved_panel.lua",
		"vgui/ttt_close_button.lua",
		"vgui/ttt_html_base.lua",
		"vgui/ttt_ammo.lua",
		"vgui/ttt_health.lua",
		"vgui/ttt_time.lua",
		"vgui/ttt_equipment_menu.lua",
		"vgui/ttt_body_inspect.lua",
		"vgui/ttt_scoreboard.lua",
		"cl_hud.lua",
		"cl_scoreboard.lua",
		"cl_hitmarkers.lua",
		"cl_crosshair_menu.lua",
		"cl_voice.lua",
		"cl_crosshair_menu.lua",
		"cl_dev_stats.lua",
		"cl_weapons.lua",
		"cl_player_outlines.lua",
		"cl_damage_positions.lua",
	},
	Shared = {
		"sh_init.lua",
		"libraries/quaternion.lua",
		"player_terror.lua",
		"sh_roles.lua",
		"sh_proper_networking.lua",
		"sh_round_system.lua",
		"player_terror.lua",
		"sh_movement.lua",
		"sh_equipment.lua",
		"sh_util.lua",
		"sh_body.lua",
		"sh_notifications.lua",
		-- "sh_dev.lua",
	},
	Resources = {
		"materials/tttrw/heart.png",
		"materials/tttrw/tbutton.png",
		"materials/tttrw/xbutton128.png",
		"materials/tttrw/transparentevil.png",
		"materials/tttrw/agree.png",
		"materials/tttrw/disagree.png",
	},
	Load = function(self)
		for _, file in ipairs(self.Shared) do
			if (SERVER) then
				AddCSLuaFile(file)
			end
			include(file)
		end

		for _, file in ipairs(SERVER and self.Server or self.Client) do
			include(file)
		end

		if (CLIENT) then return end
		
		for _, file in ipairs(self.Resources) do
			resource.AddFile(file)
		end

		for _, file in ipairs(self.Client) do
			AddCSLuaFile(file)
		end
	end
}):Load()
