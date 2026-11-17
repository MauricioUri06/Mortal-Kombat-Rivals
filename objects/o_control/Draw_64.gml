draw_set_alpha(1);
draw_set_halign(fa_center);
if (main_menu_open) {
    draw_sprite(s_menu_background, 0, 0, 0);
    draw_sprite(s_menu_logo, 0, 640 - sprite_get_width(s_menu_logo) div 2, 159);

    draw_set_valign(fa_middle);
    var _play = menu_play;
    draw_set_colour(c_black);
    draw_rectangle(_play.left - 2, _play.top + 5, _play.right + 2, _play.bottom - 1, false);
    draw_rectangle(_play.left + 5, _play.top - 2, _play.right - 5, _play.bottom + 5, false);
    var _rim = menu_play_hovered ? make_colour_rgb(245, 198, 119) : make_colour_rgb(189, 135, 74);
    var _gold_dark = make_colour_rgb(105, 65, 37);
    draw_set_colour(_gold_dark);
    draw_rectangle(_play.left, _play.top + 6, _play.right, _play.bottom - 6, false);
    draw_rectangle_colour(_play.left + 6, _play.top, _play.right - 6, _play.bottom,
        _rim, _rim, _gold_dark, _gold_dark, false);
    var _steel = menu_play_hovered ? make_colour_rgb(69, 54, 41) : make_colour_rgb(37, 35, 36);
    var _iron = make_colour_rgb(13, 13, 17);
    draw_rectangle_colour(_play.left + 3, _play.top + 3, _play.right - 3, _play.bottom - 3,
        _steel, _steel, _iron, _iron, false);
    draw_set_colour(_rim);
    var _middle = (_play.top + _play.bottom) div 2;
    draw_rectangle(_play.left + 13, _middle - 1, _play.left + 26, _middle + 1, false);
    draw_rectangle(_play.right - 26, _middle - 1, _play.right - 13, _middle + 1, false);
    draw_set_colour(make_colour_rgb(245, 236, 215));
    draw_text_transformed(640, _middle, "JUGAR", 1.5, 1.5, 0);
    draw_set_colour(make_colour_rgb(179, 191, 206));
    draw_text(640, 515, "Enter para jugar");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    exit;
}
if (selecting) {
    c_player_select_draw();
    exit;
}
if (!is_undefined(match_menu)) {
    c_match_menu_draw();
    exit;
}
draw_set_colour(make_colour_rgb(225, 233, 241));
draw_text(640, 22, "MORTAL KOMBAT RIVALS");
draw_set_halign(fa_left);

for (var _i = 0; _i < instance_number(o_fighter); _i++) {
    var _fighter = instance_find(o_fighter, _i);
    var _on_left = _fighter.player_number == 1;
    var _left = _on_left ? 42 : 830;
    var _right = _left + 408;
    var _label_x = _on_left ? _left : _right;
    var _colour = _fighter.fighter_colour;
    var _health = clamp(_fighter.hp / max(1, _fighter.hpMax), 0, 1);
    var _fill_width = round((_right - _left - 18) * _health);
    var _fill_left = _on_left ? _left + 9 : _right - 9 - _fill_width;
    var _fill_right = _fill_left + _fill_width;

    draw_set_halign(_on_left ? fa_left : fa_right);
    draw_set_colour(c_black);
    draw_text_transformed(_label_x + 1, 43, _fighter.character_name, 1.35, 1.35, 0);
    draw_set_colour(_colour);
    draw_text_transformed(_label_x, 42, _fighter.character_name, 1.35, 1.35, 0);

    // Fondo y vida quedan detrás del marco metálico del PNG.
    draw_set_colour(make_colour_rgb(20, 16, 22));
    draw_rectangle(_left + 9, 76, _right - 9, 91, false);

    if (_fill_width > 0) {
        var _fill_top = merge_colour(_colour, c_white, 0.28);
        var _fill_bottom = merge_colour(_colour, c_black, 0.48);
        draw_rectangle_colour(_fill_left, 76, _fill_right, 91, _fill_top, _fill_top, _fill_bottom, _fill_bottom, false);
        draw_set_colour(_fill_top);
        draw_rectangle(_fill_left, 76, _fill_right, 78, false);
    }
    var _object = _fighter.object_index;
    var _ice_frame = (_object == o_subzero || object_is_ancestor(_object, o_subzero))
        && shader_is_compiled(sh_health_frame_ice);
    if (_ice_frame) shader_set(sh_health_frame_ice);
    draw_sprite(s_health_frame, 0, _left - 6, 66);
    if (_ice_frame) shader_reset();

    draw_set_colour(c_white);
    draw_text(_label_x, 106, string(_fighter.hp) + " / " + string(_fighter.hpMax));
    if (_fighter.input_enabled) {
        var _special_ready = _fighter.special_cooldown == 0;
        draw_set_halign(_on_left ? fa_right : fa_left);
        draw_set_colour(_special_ready ? _colour : make_colour_rgb(183, 199, 215));
        draw_text(_on_left ? _right : _left, 106, _special_ready ? "ESPECIAL LISTO" : "RECARGANDO");
    }
}
draw_set_halign(fa_left);

draw_set_colour(make_colour_rgb(183, 199, 215));
draw_text(42, 637, "A/D mover  |  W/Espacio saltar  |  S agacharse  |  Shift deslizar  |  Clic izq golpe  |  Clic der patada  |  Q distancia  |  Alt habilidad");
draw_set_colour(make_colour_rgb(118, 143, 166));
draw_text(42, 691, "R reiniciar  /  Esc pausa  /  F1 ver colisiones");

if (instance_exists(player)) {
    if (player.dead) {
        draw_set_halign(fa_center);
        draw_set_colour(c_white);
        draw_text(640, 160, "DERROTA");
        draw_text(640, 187, global.checkpoint_activo ? "Reapareciendo en el checkpoint..." : "Reapareciendo...");
        draw_set_halign(fa_left);
    }
}
draw_set_colour(c_white);
