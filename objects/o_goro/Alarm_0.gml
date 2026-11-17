/// @description Goro se recupera de la confusion
// Vuelve a patrullar hacia donde esta mirando

if (hp <= 0) exit; // muerto: se esta desvaneciendo, no hace nada

state = "walk";
anim = 0;
hspeed = walkSpeed * sign(image_xscale);
