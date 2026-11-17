/// Dibuja un boton dorado del menu principal
function c_menu_boton(_b, _texto, _activo) {
    draw_set_colour(c_black);
    draw_rectangle(_b.left - 2, _b.top + 5, _b.right + 2, _b.bottom - 1, false);
    draw_rectangle(_b.left + 5, _b.top - 2, _b.right - 5, _b.bottom + 5, false);
    var _rim = _activo ? make_colour_rgb(245, 198, 119) : make_colour_rgb(189, 135, 74);
    var _gold_dark = make_colour_rgb(105, 65, 37);
    draw_set_colour(_gold_dark);
    draw_rectangle(_b.left, _b.top + 6, _b.right, _b.bottom - 6, false);
    draw_rectangle_colour(_b.left + 6, _b.top, _b.right - 6, _b.bottom,
        _rim, _rim, _gold_dark, _gold_dark, false);
    var _steel = _activo ? make_colour_rgb(69, 54, 41) : make_colour_rgb(37, 35, 36);
    var _iron = make_colour_rgb(13, 13, 17);
    draw_rectangle_colour(_b.left + 3, _b.top + 3, _b.right - 3, _b.bottom - 3,
        _steel, _steel, _iron, _iron, false);
    draw_set_colour(_rim);
    var _middle = (_b.top + _b.bottom) div 2;
    draw_rectangle(_b.left + 13, _middle - 1, _b.left + 26, _middle + 1, false);
    draw_rectangle(_b.right - 26, _middle - 1, _b.right - 13, _middle + 1, false);
    draw_set_colour(make_colour_rgb(245, 236, 215));
    draw_text_transformed((_b.left + _b.right) / 2, _middle, _texto, 1.5, 1.5, 0);
}
