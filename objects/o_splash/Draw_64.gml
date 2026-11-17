var _w = display_get_gui_width();
var _h = display_get_gui_height();
var _a1 = fade_in + espera; // momento en que termina de mostrarse el logo
var _a2 = _a1 + fade_out; // momento en que la pantalla queda negra
if (t < _a2) {
    // Logo sobre fondo blanco que aparece y desaparece
    var _logo = 0;
    if (t < fade_in) _logo = t / fade_in;
    else if (t < _a1) _logo = 1;
    else _logo = 1 - (t - _a1) / fade_out;
    draw_set_alpha(1);
    draw_set_colour(c_black);
    draw_rectangle(-1, -1, _w + 1, _h + 1, false);
    draw_set_alpha(_logo);
    draw_set_colour(c_white);
    draw_rectangle(-1, -1, _w + 1, _h + 1, false);
    gpu_set_texfilter(true);
    var _sc = (_h * 0.9) / sprite_get_height(s_logo_gaira);
    draw_sprite_ext(s_logo_gaira, 0, _w / 2, _h / 2, _sc, _sc, 0, c_white, _logo);
    gpu_set_texfilter(false);
} else {
    // El menu aparece gradualmente desde el negro
    draw_set_alpha(1 - (t - _a2) / menu_in);
    draw_set_colour(c_black);
    draw_rectangle(-1, -1, _w + 1, _h + 1, false);
}
draw_set_alpha(1);
draw_set_colour(c_white);
