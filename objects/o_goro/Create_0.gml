// Goro: patrulla como o_enemy_walker y embiste al ver al jugador en su misma linea.

// stats --------------------------

hp = 60;
dmg = 20;
team = 2; // del lado del jefe: solo dana al jugador
target = noone;

// movimiento ---------------------

walkSpeed = 1.5;
tackleSpeed = 9;
xCheck = 16;
range_y = 40;   // misma linea horizontal que el jugador
dazedTime = 2;
ySpeed = 0;
grav = 0.5;
fallMax = 13;  // segundos confundido despues de chocar

// comportamiento ------------------

state = "walk"; // walk, tackle, dazed
anim = 0;
hit_flash = 0;
visual_scale = 0.65;
image_xscale = visual_scale;
image_yscale = visual_scale;
image_speed = 0;
mask_index = s_fighter_mask;

if (irandom(1)) {
	hspeed = walkSpeed;
} else {
	hspeed = -walkSpeed;
	image_xscale = -visual_scale;
}

// Rango de activacion: no se mueve mientras el jugador este fuera de este rango.
// Se puede cambiar por instancia en el Creation Code (ej: xrange = 300;).
xrange = 300;   // distancia horizontal maxima al jugador
yrange = 250;   // distancia vertical maxima al jugador
pausa_hspeed = 0; // velocidad guardada mientras esta en pausa
