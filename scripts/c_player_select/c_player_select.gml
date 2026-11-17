/// Selector: crea al jugador elegido y al jefe
/// Se ejecuta en el contexto de o_control
function c_player_clear() {
    with (o_att) instance_destroy();
    with (o_fighter) instance_destroy();
    // Los enemigos de la room no se borran aqui
    player = noone;
    boss = noone;
    baraka = noone;
    goro = noone;
}

function c_player_start(_choice) {
    c_player_clear();
    selected_character = clamp(_choice, 0, 1);
    global.selected_character = selected_character;
    var _player_object = selected_character == 0 ? o_player_sz : o_player_sc;

    // El jugador aparece en el o_spawn_player
    var _sx = 160;
    var _sy = room_height - 64;
    if (global.checkpoint_activo) {
        // Reaparece en el ultimo checkpoint encendido
        _sx = global.checkpoint_x;
        _sy = global.checkpoint_y;
    } else if (instance_exists(o_spawn_player)) {
        var _spawn = instance_find(o_spawn_player, 0);
        _sx = _spawn.x;
        _sy = _spawn.y;
    } else {
        show_debug_message("AVISO: falta o_spawn_player en la room; el jugador aparece en una posicion por defecto.");
    }
    if (!layer_exists("Instances")) layer_create(0, "Instances");
    player = instance_create_layer(_sx, _sy, "Instances", _player_object);
    with (player) {
        // Si quedo dentro del suelo, lo sube
        var _n = 0;
        while (place_meeting(x, y, o_solid) && _n < 256) { y--; _n++; }
        spawn_x = x;
        spawn_y = y;
    }

    // Los enemigos se colocan a mano en la room
    boss = noone;
    baraka = noone;
    goro = noone;
    with (o_enemy) target = other.player;

    // El jefe aparece en el o_spawn_boss si existe
    if (instance_exists(o_spawn_boss)) {
        var _bs = instance_find(o_spawn_boss, 0);
        var _boss_object = selected_character == 0 ? o_boss_sc : o_boss_sz;
        boss = instance_create_layer(_bs.x, _bs.y, "Instances", _boss_object);
        boss.target = player;
        with (boss) {
            var _nb = 0;
            while (place_meeting(x, y, o_solid) && _nb < 256) { y--; _nb++; }
            spawn_x = x;
            spawn_y = y;
        }
    }

    // La camara de la vista sigue al jugador
    camera_set_view_target(view_camera[0], player);
    selecting = false;
}

function c_player_select_input(_left, _right, _confirm) {
    if (!selecting) exit;
    var _antes = selected_character;
    if (_left) selected_character = 0;
    if (_right) selected_character = 1;
    if (selected_character != _antes) c_sfx(snd_menu_move, 0.7, 0);
    if (_confirm) {
        c_sfx(snd_menu_select, 0.8, 0);
        // Espacio confirma sin hacer saltar al jugador
        keyboard_clear(vk_space);
        c_player_start(selected_character);
    }
}

function c_player_select_draw() {
    // Franja central del arte del templo de fondo
    draw_sprite_part_ext(s_menu_background, 0, 424, 20, 432, 243, 0, 0,
        1280 / 432, 720 / 243, c_white, 1);
    draw_set_colour(c_black);
    draw_set_alpha(0.45);
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_alpha(1);

    var _bronze = make_colour_rgb(188, 143, 89);
    var _bronze_dark = make_colour_rgb(74, 52, 40);
    var _cream = make_colour_rgb(245, 224, 185);
    var _iron = make_colour_rgb(13, 13, 18);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(c_black);
    draw_text_transformed(642, 83, "ELIGE TU LUCHADOR", 2.45, 2.45, 0);
    draw_set_colour(_cream);
    draw_text_transformed(640, 80, "ELIGE TU LUCHADOR", 2.45, 2.45, 0);
    draw_set_colour(_bronze);
    draw_line(470, 112, 630, 112);
    draw_line(650, 112, 810, 112);
    draw_rectangle(638, 110, 642, 114, false);

    for (var _card = 0; _card < 2; _card++) {
        var _left = 190 + _card * 500;
        var _right = _left + 400;
        var _center = _left + 200;
        var _top = 152;
        var _bottom = 584;
        var _selected = selected_character == _card;
        var _colour = _card == 0 ? make_colour_rgb(72, 201, 255) : make_colour_rgb(255, 197, 66);

        draw_set_colour(c_black);
        draw_rectangle(_left - 5, _top - 4, _right + 5, _bottom + 8, false);
        var _outer = _selected ? _bronze : merge_colour(_bronze, _iron, 0.40);
        draw_rectangle_colour(_left, _top, _right, _bottom,
            _outer, _outer, _bronze_dark, _bronze_dark, false);
        draw_set_colour(_iron);
        draw_rectangle(_left + 3, _top + 3, _right - 3, _bottom - 3, false);
        draw_sprite_part_ext(s_pause_panel, 0, 35, 84, 410, 245, _left + 7, _top + 7,
            386 / 410, 418 / 245, c_white, 1);

        // Luz detras del sprite y sombra bajo los pies
        var _light = merge_colour(_colour, _iron, 0.67);
        draw_set_alpha(_selected ? 0.48 : 0.28);
        draw_ellipse_colour(_center - 159, 197, _center + 159, 498, _light, _iron, false);
        draw_set_alpha(0.57);
        draw_set_colour(c_black);
        draw_ellipse(_center - 108, 474, _center + 108, 499, false);
        draw_set_alpha(1);

        var _sprite = _card == 0 ? s_subzero_stand : s_scorpion_stand;
        var _frame = floor(current_time * 0.008) mod sprite_get_number(_sprite);
        draw_sprite_ext(_sprite, _frame, _center, 483, _card == 0 ? 2 : -2, 2, 0,
            c_white, _selected ? 1 : 0.84);

        draw_set_colour(_iron);
        draw_rectangle(_left + 8, 512, _right - 8, _bottom - 8, false);
        draw_set_colour(_selected ? _colour : _bronze_dark);
        draw_line(_left + 8, 512, _right - 8, 512);
        draw_set_colour(_selected ? _colour : _cream);
        draw_text_transformed(_center, 536, _card == 0 ? "SUB-ZERO" : "SCORPION", 1.7, 1.7, 0);
        if (_selected) {
            draw_set_colour(_cream);
            draw_text(_center, 561, "SELECCIONADO");
            draw_set_colour(_colour);
            draw_rectangle(_left + 4, _top + 4, _right - 4, _bottom - 4, true);
            draw_line_width(_left, _top, _left + 42, _top, 2);
            draw_line_width(_right - 42, _top, _right, _top, 2);
        }
        draw_set_colour(_iron);
        draw_rectangle(_left + 16, _top + 16, _left + 49, _top + 45, false);
        draw_set_colour(_selected ? _colour : _bronze);
        draw_rectangle(_left + 16, _top + 16, _left + 49, _top + 45, true);
        draw_text(_left + 32, _top + 31, string(_card + 1));
    }

    draw_set_colour(c_black);
    draw_set_alpha(0.58);
    draw_rectangle(225, 622, 1055, 674, false);
    draw_set_alpha(1);
    draw_set_colour(_bronze_dark);
    draw_line(225, 622, 1055, 622);
    draw_set_colour(_cream);
    draw_text(640, 648, "A / D o flechas: elegir   |   Enter / Espacio: confirmar   |   Esc: volver");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
}
