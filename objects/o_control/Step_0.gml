if (global.test_mode) { c_character_self_test(); exit; }
if (keyboard_check_pressed(vk_f1)) global.debug_hitboxes = !global.debug_hitboxes;
if (pending_start >= 0) {
    var _choice = pending_start;
    pending_start = -1;
    c_player_start(_choice);
    exit;
}
if (selecting) {
    c_player_select_input(
        keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("1")),
        keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("2")),
        keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space));
    exit;
}
if (keyboard_check_pressed(vk_escape)) { global.selected_character = -1; global.checkpoint_activo = false; room_restart(); exit; }
if (keyboard_check_pressed(ord("R"))) { global.selected_character = selected_character; room_restart(); exit; }

// Al morir, reaparece solo en el ultimo checkpoint (o en el inicio) tras 2 segundos.
if (instance_exists(player) && player.dead) {
    death_timer++;
    if (death_timer >= 2 * game_get_speed(gamespeed_fps)) {
        global.selected_character = selected_character;
        room_restart();
        exit;
    }
} else {
    death_timer = 0;
}
