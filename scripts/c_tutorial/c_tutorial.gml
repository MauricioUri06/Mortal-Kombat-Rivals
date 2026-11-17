/// Dibuja un cartel de tutorial con teclas y texto
/// El texto puede ser uno o uno por tecla
function c_tutorial_dibujar(_x, _y, _keys, _txt, _alpha) {
    var _sc = 1.3; // tamano del texto dentro de las teclas
    var _tsc = 1.15; // tamano del texto explicativo debajo
    var _pad = 8;
    var _h = 30;
    var _gap = 14;
    var _por_tecla = is_array(_txt);
    var _n = array_length(_keys);

    // ancho de cada columna de tecla y texto
    var _anchos = array_create(_n, 0);
    var _cols = array_create(_n, 0);
    var _total = 0;
    for (var _i = 0; _i < _n; _i++) {
        _anchos[_i] = max(_h, string_width(_keys[_i]) * _sc + _pad * 2);
        _cols[_i] = _anchos[_i];
        if (_por_tecla && _i < array_length(_txt)) _cols[_i] = max(_cols[_i], string_width(_txt[_i]) * _tsc + 6);
        _total += _cols[_i] + (_i > 0 ? _gap : 0);
    }

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var _cx = _x - _total / 2;
    var _ky = _y - _h - 4;
    for (var _i = 0; _i < _n; _i++) {
        var _w = _anchos[_i];
        var _mid = _cx + _cols[_i] / 2;
        var _kx = _mid - _w / 2;
        // sombra, cuerpo y borde de cada tecla
        draw_set_alpha(_alpha * 0.6);
        draw_set_colour(c_black);
        draw_roundrect(_kx + 2, _ky + 4, _kx + _w + 2, _ky + _h + 4, false);
        draw_set_alpha(_alpha);
        draw_set_colour(make_colour_rgb(32, 30, 38));
        draw_roundrect(_kx, _ky, _kx + _w, _ky + _h, false);
        draw_set_colour(make_colour_rgb(230, 204, 145));
        draw_roundrect(_kx, _ky, _kx + _w, _ky + _h, true);
        draw_set_colour(c_white);
        draw_text_transformed(_mid, _ky + _h / 2, _keys[_i], _sc, _sc, 0);
        if (_por_tecla && _i < array_length(_txt)) c_tutorial_texto(_mid, _y + 14, _txt[_i], _tsc);
        _cx += _cols[_i] + _gap;
    }
    if (!_por_tecla) c_tutorial_texto(_x, _y + 14, _txt, _tsc);

    draw_set_alpha(1);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

/// Texto claro con contorno oscuro para leerse bien
function c_tutorial_texto(_x, _y, _t, _sc) {
    draw_set_colour(c_black);
    draw_text_transformed(_x - 1, _y, _t, _sc, _sc, 0);
    draw_text_transformed(_x + 1, _y, _t, _sc, _sc, 0);
    draw_text_transformed(_x, _y - 1, _t, _sc, _sc, 0);
    draw_text_transformed(_x, _y + 1, _t, _sc, _sc, 0);
    draw_set_colour(c_white);
    draw_text_transformed(_x, _y, _t, _sc, _sc, 0);
}
