/// @description Baraka se prepara para saltar
// Antes de saltar se agacha un momento

if (hp <= 0) exit; // muerto: se esta desvaneciendo, no hace nada

if (state != "idle" || !instance_exists(target)) {
    alarm[0] = 10;
    exit;
}
// Fuera de rango no salta, revisa luego
if (target.dead || abs(target.x - x) > xrange || abs(target.y - y) > yrange) {
    alarm[0] = 10;
    exit;
}

state = "prep";
anim = 0;

if (target.x > x) image_xscale = visual_scale; else image_xscale = -visual_scale;

alarm[0] = irandom_range(jumpTime / 2, jumpTime);
