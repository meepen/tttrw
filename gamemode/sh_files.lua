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
		"sv_karma.lua",
		"sv_damage_positions.lua",
	},
	Client = {
		"cl_hud_helpers.lua",
		"cl_player_status.lua",
		"vgui/ttt_skin.lua",
		"vgui/ttt_centered_wrap.lua",
		"vgui/ttt_curved_panel.lua",
		"vgui/ttt_hud_customizable.lua",
		"vgui/ttt_close_button.lua",
		"vgui/ttt_hud_base_elements.lua",
		"vgui/ttt_ammo.lua",
		"vgui/ttt_equipment_menu.lua",
		"vgui/ttt_body_inspect.lua",
		"vgui/ttt_scoreboard.lua",
		"vgui/ttt_weapon_select.lua",
		"vgui/ttt_dna_menu.lua",
		"vgui/ttt_radio.lua",
		"vgui/ttt_settings.lua",
		"vgui/ttt_endround.lua",
		"vgui/ttt_voice.lua",
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
		"cl_spectator.lua",
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
		"sh_radio.lua",
		"sh_dev.lua",
		"sh_chat.lua",
	},
	Resources = {
		"materials/tttrw/heart.png",
		"materials/tttrw/tbutton.png",
		"materials/tttrw/xbutton128.png",
		"materials/tttrw/transparentevil.png",
		"materials/tttrw/transparentgood.png",
		"materials/tttrw/agree.png",
		"materials/tttrw/disagree.png",
		"materials/tttrw/roles/innocent.png",
		"materials/tttrw/roles/detective.png",
		"materials/tttrw/headshot.png",
		"materials/tttrw/dna.png",
		"materials/tttrw/expired_dna.png",
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
