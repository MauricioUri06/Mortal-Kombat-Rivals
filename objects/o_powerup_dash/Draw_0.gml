// Brillo pulsante detras del icono del power-up
var _s = 1 + sin(t / 8) * 0.12;
gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, 1.6 * _s, 1.6 * _s, 0, make_colour_rgb(120, 120, 120), 0.6);
gpu_set_blendmode(bm_normal);
draw_self();
