draw_self();
// Brilla cuando Scorpion lo tiene a su alcance
var _me = id;
var _en_rango = false;
with (o_player_sc) {
    if (!dead && state != "hook" && c_gancho_buscar() == _me) _en_rango = true;
}
if (_en_rango) {
    var _cx = c_gancho_centro_x(id);
    var _cy = c_gancho_centro_y(id);
    draw_set_alpha(0.5 + 0.3 * sin(current_time / 120));
    draw_set_colour(make_colour_rgb(242, 194, 48));
    draw_circle(_cx, _cy, (bbox_right - bbox_left) * 0.75, true);
    draw_circle(_cx, _cy, (bbox_right - bbox_left) * 0.75 + 1, true);
    draw_set_alpha(1);
    draw_set_colour(c_white);
}
