// Cadena del gancho: de la mano de Scorpion a la argolla.
if (state == "hook" && instance_exists(hook_target)) {
    var _ax = x + (right ? 1 : -1) * 52; // mano extendida de s_animacion_gancho
    var _ay = y - HOOK_HAND_Y;
    var _gx = c_gancho_centro_x(hook_target);
    var _gy = c_gancho_centro_y(hook_target);
    draw_set_colour(make_colour_rgb(109, 113, 122));
    draw_line_width(_ax, _ay, _gx, _gy, 2);
    draw_set_colour(make_colour_rgb(207, 210, 214));
    draw_line(_ax, _ay - 1, _gx, _gy - 1);
    draw_set_colour(c_white);
}
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

// Aviso "ALT" sobre la cabeza cuando Sub-Zero tiene un puente a su alcance.
if (input_enabled && !dead && projectile_object == o_iceball
&& (state == "stand" || state == "run" || state == "crouch" || state == "jump" || state == "fall" || state == "land" || state == "wall" || state == "wall_jump")) {
    if (c_puente_buscar() != noone) {
        var _px = x;
        var _py = y - 112 + 3 * sin(current_time / 180);
        draw_set_alpha(0.85);
        draw_set_colour(make_colour_rgb(14, 28, 44));
        draw_roundrect(_px - 22, _py - 13, _px + 22, _py + 13, false);
        draw_set_alpha(1);
        draw_set_colour(make_colour_rgb(115, 222, 255));
        draw_roundrect(_px - 22, _py - 13, _px + 22, _py + 13, true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_colour(c_white);
        draw_text(_px, _py, "ALT");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
}
draw_set_colour(c_white);
