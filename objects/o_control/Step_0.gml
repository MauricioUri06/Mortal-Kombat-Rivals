if (global.test_mode) { c_character_self_test(); exit; }
if (keyboard_check_pressed(vk_f1)) global.debug_hitboxes = !global.debug_hitboxes;
if (selecting) {
    c_player_select_input(
        keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("1")),
        keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("2")),
        keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space));
    exit;
}
if (keyboard_check_pressed(vk_escape)) { room_restart(); exit; }
if (keyboard_check_pressed(ord("R"))) c_player_start(selected_character);
