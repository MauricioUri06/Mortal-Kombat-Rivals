// Como o_jumper: el cuadro depende de si esta en el suelo o en el aire.
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
        // Horizontal todo el salto; encoge las piernas solo a punto de tocar el suelo.
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
                hit_flash > 0 ? c_red : c_white, 1);

if (global.debug_hitboxes) {
	// Rango de activacion (F1).
	draw_set_colour(c_yellow);
	draw_rectangle(x - xrange, y - yrange, x + xrange, y + yrange, true);
    draw_set_colour(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_colour(c_white);
}
