if (instance_exists(owner)) {
    draw_set_colour(make_colour_rgb(109, 113, 122));
    draw_line_width(owner.x + facing * 30, owner.y - 53, x, y, 2);
    draw_set_colour(make_colour_rgb(207, 210, 214));
    draw_line(owner.x + facing * 30, owner.y - 54, x, y - 1);
    draw_set_colour(c_white);
}
draw_self();
