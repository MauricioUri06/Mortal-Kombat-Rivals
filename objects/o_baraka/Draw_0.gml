// El cuadro depende del estado del salto
var _frame = 0;
switch (state) {
    case "idle":
        sprite_index = s_baraka_idle;
        _frame = floor(anim) mod 8;
    break;
    case "prep":
        sprite_index = s_baraka_jump;
        _frame = min(1, floor(anim));
    break;
    case "air":
        sprite_index = s_baraka_jump;
        // Horizontal en el aire, encoge piernas al aterrizar
        if (ySpeed > 0 && collision_rectangle(x - 12, y, x + 12, y + 24, o_terrain, 0, 1)) _frame = 5;
        else _frame = 2 + min(2, floor(anim));
    break;
    case "land":
        sprite_index = s_baraka_jump;
        _frame = 6 + min(1, floor(anim));
    break;
}
image_index = _frame;

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0,
                hit_flash > 0 ? c_red : c_white, muriendo ? fade : 1);
