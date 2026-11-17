// El sprite depende del estado de Goro
switch (state) {
	case "walk": sprite_index = s_goro_walk; break;
	case "tackle": sprite_index = s_goro_tackle; break;
	case "dazed": sprite_index = s_goro_dazed; break;
}
image_index = floor(anim) mod 8;

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0,
                hit_flash > 0 ? c_red : c_white, muriendo ? fade : 1);
