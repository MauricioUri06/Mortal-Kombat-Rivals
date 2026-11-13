draw_set_alpha(1);
draw_set_halign(fa_center);
if (selecting) {
    draw_set_colour(make_colour_rgb(10, 15, 24));
    draw_rectangle(0, 0, 1280, 720, false);
    draw_set_colour(c_white);
    draw_text_transformed(640, 64, "ELIGE TU LUCHADOR", 2, 2, 0);
    draw_set_colour(make_colour_rgb(173, 190, 210));
    draw_text(640, 112, "MORTAL KOMBAT RIVALS");

    for (var _card = 0; _card < 2; _card++) {
        var _x = 250 + _card * 420;
        var _selected = selected_character == _card;
        var _colour = _card == 0 ? make_colour_rgb(72, 201, 255) : make_colour_rgb(255, 197, 53);
        draw_set_colour(_selected ? _colour : make_colour_rgb(48, 63, 81));
        draw_rectangle(_x - 3, 177, _x + 363, 538, false);
        draw_set_colour(make_colour_rgb(21, 30, 43));
        draw_rectangle(_x, 180, _x + 360, 535, false);
        var _sprite = _card == 0 ? s_subzero_stand : s_scorpion_stand;
        var _frame = floor(current_time * 0.008) mod sprite_get_number(_sprite);
        draw_sprite_ext(_sprite, _frame, _x + 180, 444, 1.25, 1.25, 0, c_white, 1);
        draw_set_colour(_colour);
        draw_text_transformed(_x + 180, 472, _card == 0 ? "SUB-ZERO" : "SCORPION", 1.5, 1.5, 0);
        draw_set_colour(c_white);
        draw_text(_x + 180, 510, _selected ? "SELECCIONADO" : (_card == 0 ? "[1]" : "[2]"));
    }

    draw_set_colour(c_white);
    draw_text(640, 578, "A / D o flechas: elegir   |   Enter o Espacio: jugar");
    draw_set_colour(make_colour_rgb(173, 190, 210));
    draw_text(640, 614, "Mover: A / D o flechas   |   Saltar: W o Espacio");
    draw_text(640, 642, "Clic izquierdo: golpe   |   Clic derecho: ataque a distancia   |   Shift: deslizamiento");
    draw_set_halign(fa_left);
    draw_set_colour(c_white);
    exit;
}
draw_set_colour(make_colour_rgb(225, 233, 241));
draw_text(640, 22, "MORTAL KOMBAT RIVALS");
draw_set_halign(fa_left);

for (var _i = 0; _i < instance_number(o_fighter); _i++) {
    var _fighter = instance_find(o_fighter, _i);
    var _left = _fighter.player_number == 1 ? 42 : 830;
    draw_set_colour(_fighter.fighter_colour);
    draw_text(_left, 42, _fighter.character_name);
    draw_set_colour(make_colour_rgb(31, 45, 62));
    draw_rectangle(_left, 68, _left + 408, 88, false);
    draw_set_colour(_fighter.fighter_colour);
    draw_rectangle(_left + 2, 70, _left + 2 + 404 * _fighter.hp / _fighter.hpMax, 86, false);
    draw_set_colour(c_white);
    draw_text(_left, 95, string(_fighter.hp) + " / " + string(_fighter.hpMax));
    if (_fighter.input_enabled) {
        draw_text(_left + 180, 95, _fighter.special_cooldown == 0 ? "ESPECIAL LISTO" : "RECARGANDO");
    }
}

draw_set_colour(make_colour_rgb(183, 199, 215));
draw_text(42, 637, "Mover: A/D o flechas  |  Saltar: W o Espacio  |  Clic izq: golpe  |  Clic der: distancia  |  Shift: deslizar");
draw_set_colour(make_colour_rgb(118, 143, 166));
draw_text(42, 691, "R reiniciar  /  Esc elegir personaje  /  F1 ver colisiones");

if (instance_exists(player)) {
    if (player.dead) {
        draw_set_halign(fa_center);
        draw_set_colour(c_white);
        draw_text(640, 160, "DERROTA");
        draw_text(640, 187, "R para reiniciar  /  Esc para elegir personaje");
        draw_set_halign(fa_left);
    }
}
if (instance_exists(boss)) {
    if (boss.dead) {
        draw_set_halign(fa_center);
        draw_set_colour(c_white);
        draw_text(640, 160, "VICTORIA");
        draw_text(640, 187, "R para reiniciar  /  Esc para elegir personaje");
        draw_set_halign(fa_left);
    }
}
draw_set_colour(c_white);
