if (instance_exists(o_splash)) exit; // mientras se muestra el logo, sin menu
// Musica del menu en inicio y selector
var _menu_music_on = main_menu_open || (selecting && pending_start < 0);
if (!variable_global_exists("menu_music")) global.menu_music = -1;
if (_menu_music_on) {
    if (global.menu_music < 0 || !audio_is_playing(global.menu_music)) {
        // Al terminar vuelve a sonar desde el segundo quince
        global.menu_music = audio_play_sound(snd_menu_music, 10, false, 1, 15);
    }
} else if (global.menu_music >= 0) {
    audio_stop_sound(global.menu_music);
    global.menu_music = -1;
}
// Musica del nivel, mas baja con menus encima
c_musica_nivel_update(!_menu_music_on, !is_undefined(match_menu));
if (!is_undefined(match_menu)) {
    c_match_menu_input();
    exit;
}
if (main_menu_open) {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    menu_play_hovered = point_in_rectangle(_mx, _my, menu_play.left, menu_play.top, menu_play.right, menu_play.bottom);
    menu_salir_hovered = point_in_rectangle(_mx, _my, menu_salir.left, menu_salir.top, menu_salir.right, menu_salir.bottom);
    if (menu_play_hovered) menu_opcion = 0;
    else if (menu_salir_hovered) menu_opcion = 1;
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) menu_opcion = 0;
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) menu_opcion = 1;
    var _click = mouse_check_button_pressed(mb_left);
    var _enter = keyboard_check_pressed(vk_enter);
    if ((_enter && menu_opcion == 0) || (menu_play_hovered && _click)) {
        c_sfx(snd_menu_select, 0.8, 0);
        main_menu_open = false;
    } else if ((_enter && menu_opcion == 1) || (menu_salir_hovered && _click)) {
        game_end(); // cierra el juego y vuelve al escritorio
    }
    exit;
}
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
    c_sfx(snd_pause, 0.8, 0);
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

// Atajo con Supr: pasa el nivel, o en el nivel del jefe lo derrota
if (keyboard_check_pressed(vk_delete) && instance_exists(player) && !player.dead) {
    if (instance_exists(boss)) {
        if (!boss.dead) {
            boss.invi = 0; // que el golpe entre aunque este parpadeando
            c_fighter_hit(boss, boss.hp, player, "punch", boss.x > player.x ? 1 : -1);
        }
    } else {
        c_transicion_iniciar(-1);
    }
}

// Al morir, el nivel empieza desde el comienzo
if (instance_exists(player) && player.dead && !instance_exists(boss)) { // en el duelo decide el fatality
    death_timer++;
    if (death_timer >= 2 * game_get_speed(gamespeed_fps)) {
        global.selected_character = selected_character;
        global.checkpoint_activo = false;
        global.checkpoints_usados = [];
        c_reiniciar_room();
        exit;
    }
} else {
    death_timer = 0;
}
