// Goro: patrulla y embiste al ver al jugador

hp = 60;
dmg = 20;
team = 2; // equipo del jefe: solo dana al jugador
target = noone;

walkSpeed = 1.5;
tackleSpeed = 9;
xCheck = 16;
range_y = 40; // diferencia de altura para ver al jugador
dazedTime = 2;
ySpeed = 0;
grav = 0.5;
fallMax = 13; // velocidad maxima de caida por la gravedad

state = "walk"; // estados posibles: walk, tackle y dazed
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

// Rango de activacion: quieto si el jugador esta lejos
// Se puede cambiar por instancia en Creation Code
xrange = 300; // distancia horizontal maxima para activarse
yrange = 250; // distancia vertical maxima para activarse
pausa_hspeed = 0; // velocidad guardada mientras esta en pausa
muriendo = false; // true cuando murio y se esta desvaneciendo
fade = 1; // opacidad actual mientras se desvanece
