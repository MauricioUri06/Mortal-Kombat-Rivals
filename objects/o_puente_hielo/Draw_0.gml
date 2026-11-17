// Antes de crearlo se ve una silueta transparente
if (!activo) {
    draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, 0, make_colour_rgb(150, 220, 255), silueta_alpha);
    exit;
}

// Parpadea al final para avisar que se rompe
var _alpha = 1;
if (!desapareciendo && timer > max(0, duracion - aviso) * game_get_speed(gamespeed_fps)) {
    _alpha = (timer div 4) mod 2 == 0 ? 0.45 : 1;
}

if (anim < 3) {
    var _w = (bbox_right - bbox_left + 1) / sprite_get_width(s_animacion_puente);
    var _h = (bbox_bottom - bbox_top + 1) / sprite_get_height(s_animacion_puente);
    var _frame = clamp(floor(anim), 0, sprite_get_number(s_animacion_puente) - 1);
    if (desde_derecha) {
        // Espejada: crece desde el borde derecho
        draw_sprite_ext(s_animacion_puente, _frame, bbox_right + 1, bbox_top, -_w, _h, 0, c_white, _alpha);
    } else {
        draw_sprite_ext(s_animacion_puente, _frame, bbox_left, bbox_top, _w, _h, 0, c_white, _alpha);
    }
} else {
    draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, 0, c_white, _alpha);
}
