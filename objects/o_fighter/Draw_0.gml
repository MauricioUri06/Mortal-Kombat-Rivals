// Dibujar no cambia la fisica ni el estado de las animaciones.
var _colour = frozen_timer > 0 ? make_colour_rgb(115, 222, 255) : c_white;
var _alpha = (invi > 0 && frozen_timer == 0 && !dead && (invi div 3) mod 2 == 0) ? 0.5 : 1;
draw_sprite_ext(anim_sprite, floor(anim_frame), x, y,
                right ? visual_scale : -visual_scale, visual_scale, 0, _colour, _alpha);

if (frozen_timer > 0) {
    draw_set_alpha(0.25);
    draw_set_colour(make_colour_rgb(100, 218, 255));
    draw_roundrect(x - 19, y - 85, x + 19, y, false);
    draw_set_alpha(1);
}

if (global.debug_hitboxes) {
    draw_set_colour(c_lime);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_colour(c_white);
    draw_text(x - 30, y - 112, state);
}
draw_set_colour(c_white);
