draw_set_alpha(1);
draw_set_halign(fa_center);
if (main_menu_open) {
    draw_sprite(s_menu_background, 0, 0, 0);
    draw_sprite(s_menu_logo, 0, 640 - sprite_get_width(s_menu_logo) div 2, 159);

    draw_set_valign(fa_middle);
    c_menu_boton(menu_play, "JUGAR", menu_opcion == 0);
    c_menu_boton(menu_salir, "SALIR", menu_opcion == 1);
    draw_set_colour(make_colour_rgb(179, 191, 206));
    draw_text(640, 600, "Flechas: elegir   |   Enter: aceptar");

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

    // Fondo y vida quedan detras del marco metalico
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
draw_set_colour(make_colour_rgb(118, 143, 166));

if (instance_exists(player)) {
    if (player.dead) {
        draw_set_halign(fa_center);
        draw_set_colour(c_white);
        draw_text(640, 160, "DERROTA");
        draw_text(640, 187, "Volviendo al comienzo del nivel...");
        draw_set_halign(fa_left);
    }
}
draw_set_colour(c_white);

if (instance_exists(boss) && boss.dead) {
    draw_set_halign(fa_center);
    draw_set_colour(c_white);
    draw_text(640, 160, "VICTORIA");
    draw_text(640, 187, "R para reiniciar  /  Esc para pausar");
    draw_set_halign(fa_left);
}
