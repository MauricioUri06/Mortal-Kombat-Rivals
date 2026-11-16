if (instance_exists(owner)) {
    // Recta desde los eslabones de la mano hasta la cola de la lanza.
    var _ax = owner.x + facing * anchor_x;
    var _ay = owner.y + anchor_y;
    var _tail = x - facing * 40 * scale;
    draw_set_colour(make_colour_rgb(109, 113, 122));
    draw_line_width(_ax, _ay, _tail, y, 2);
    draw_set_colour(make_colour_rgb(207, 210, 214));
    draw_line(_ax, _ay - 1, _tail, y - 1);
    draw_set_colour(c_white);
}
draw_self();
