// Baraka: enemigo que salta hacia el jugador

hp = 30;
dmg = 15;
team = 2; // equipo del jefe: solo dana al jugador
target = noone;

jumpPower = 8;
jumpTime = 140;

alarm[0] = irandom_range(jumpTime / 2, jumpTime);

xSpeed = 0;
xSpeedMax = 5;

ySpeed = 0;
fallMax = 9;
grav = 0.3;

ground = 0;

state = "idle"; // estados posibles: idle, prep, air, land
anim = 0;
hit_flash = 0;
visual_scale = 0.65;
image_xscale = visual_scale;
image_yscale = visual_scale;
image_speed = 0;
mask_index = s_fighter_mask;

// Rango de activacion: quieto si el jugador esta lejos
// Se puede cambiar por instancia en Creation Code
xrange = 300; // distancia horizontal maxima para activarse
yrange = 250; // distancia vertical maxima para activarse
muriendo = false; // true cuando murio y se esta desvaneciendo
fade = 1; // opacidad actual mientras se desvanece
