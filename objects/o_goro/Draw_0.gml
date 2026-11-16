// El sprite depende del estado: caminar, embestir o confundido.
switch (state) {
	case "walk": sprite_index = s_goro_walk; break;
	case "tackle": sprite_index = s_goro_tackle; break;
	case "dazed": sprite_index = s_goro_dazed; break;
}
image_index = floor(anim) mod 8;

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0,
                hit_flash > 0 ? c_red : c_white, 1);

if (global.debug_hitboxes) {
	draw_set_colour(c_lime);
	draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
	draw_set_colour(c_white);
}
