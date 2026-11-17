if (global.test_mode) { c_character_self_test(); exit; }
if (!is_undefined(match_menu)) {
    c_match_menu_input();
    exit;
}
if (main_menu_open) {
    menu_play_hovered = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
        menu_play.left, menu_play.top, menu_play.right, menu_play.bottom);
    if (keyboard_check_pressed(vk_enter) || (menu_play_hovered && mouse_check_button_pressed(mb_left))) {
        main_menu_open = false;
    }
    exit;
}
if (keyboard_check_pressed(vk_f1)) global.debug_hitboxes = !global.debug_hitboxes;
if (pending_start >= 0) {
    var _choice = pending_start;
    pending_start = -1;
    c_player_start(_choice);
    exit;
}
if (selecting) {
    if (keyboard_check_pressed(vk_escape)) {
        main_menu_open = true;
        exit;
    }
    c_player_select_input(
        keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A")) || keyboard_check_pressed(ord("1")),
        keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D")) || keyboard_check_pressed(ord("2")),
        keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space));
    exit;
}
if (keyboard_check_pressed(vk_escape)) {
    c_match_menu_open({
        title: "PAUSA",
        subtitle: "",
        accent: make_colour_rgb(245, 195, 116),
        top: 292,
        escape_action: MatchMenuAction.resume,
        hint: "Flechas   Enter: elegir   Esc: seguir",
        options: [
            { label: "CONTINUAR", action: MatchMenuAction.resume },
            { label: "REINICIAR", action: MatchMenuAction.restart },
            { label: "VOLVER AL INICIO", action: MatchMenuAction.main_menu }
        ]
    });
    exit;
}
if (keyboard_check_pressed(ord("R"))) {
    global.selected_character = selected_character;
    room_restart();
    exit;
}

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
