// Baraka: enemigo saltador con el comportamiento de o_jumper de la referencia.

// stats --------------------------

hp = 30;
dmg = 15;
team = 2; // del lado del jefe: solo dana al jugador
target = noone;

jumpPower = 8;
jumpTime = 140;

alarm[0] = irandom_range(jumpTime / 2, jumpTime);

// movimiento ---------------------

xSpeed = 0;
xSpeedMax = 5;

ySpeed = 0;
fallMax = 9;
grav = 0.3;

ground = 0;

// dibujo -------------------------

state = "idle"; // idle, prep, air, land
anim = 0;
hit_flash = 0;
visual_scale = 0.65;
image_xscale = visual_scale;
image_yscale = visual_scale;
image_speed = 0;
mask_index = s_fighter_mask;
