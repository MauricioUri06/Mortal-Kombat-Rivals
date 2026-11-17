// Kitana: se queda quieta, mira al jugador si esta en su linea y le lanza su abanico.

// stats --------------------------

hp = 40;
team = 2; // del lado del jefe: solo dana al jugador
target = noone;

range_y = 40;   // diferencia vertical maxima para lanzar
xrange = 560;   // distancia horizontal maxima del abanico
ySpeed = 0;
grav = 0.5;
fallMax = 13;
throwTime = 3;  // segundos entre abanicos

alarm[0] = throwTime * game_get_speed(gamespeed_fps);

// comportamiento ------------------

state = "idle"; // idle, throw
anim = 0;
thrown = false;
hit_flash = 0;
visual_scale = 0.65;
image_xscale = visual_scale;
image_yscale = visual_scale;
image_speed = 0;
mask_index = s_fighter_mask;
