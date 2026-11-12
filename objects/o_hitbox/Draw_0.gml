if (global.debug_hitboxes) {
    draw_set_colour(c_red);
    draw_rectangle(x - half_width, y - half_height, x + half_width, y + half_height, true);
    draw_set_colour(c_white);
}
