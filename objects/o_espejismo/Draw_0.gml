if (spr < 0) exit;
// La niebla pinta el sprite de un color
gpu_set_fog(true, col, 0, 0);
draw_sprite_ext(spr, frame, x, y, xs, ys, 0, c_white, alpha);
gpu_set_fog(false, c_black, 0, 0);
