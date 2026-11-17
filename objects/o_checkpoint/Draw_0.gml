var _frames = sprite_get_number(sprite_index);
var _frame = activo ? 1 + (floor(anim) mod max(1, _frames - 1)) : 0;
draw_sprite_ext(sprite_index, _frame, x, y, image_xscale, image_yscale, 0, c_white, 1);

// Aviso de vida al encenderse el checkpoint
if (curar_fx > 0) {
    var _t = 1 - curar_fx / 45;
    draw_set_alpha(1 - _t);
    draw_set_halign(fa_center);
    draw_set_colour(make_colour_rgb(120, 255, 140));
    draw_text(x, bbox_top - 16 - 24 * _t, "+VIDA");
    draw_set_halign(fa_left);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
