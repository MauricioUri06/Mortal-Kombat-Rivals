/// @description Jump
// Como o_jumper, pero antes de saltar se agacha un momento (estado "prep").

if (state != "idle" || !instance_exists(target)) {
    alarm[0] = 10;
    exit;
}
// Fuera de rango: no salta (vuelve a revisar en un momento).
if (target.dead || abs(target.x - x) > xrange || abs(target.y - y) > yrange) {
    alarm[0] = 10;
    exit;
}

state = "prep";
anim = 0;

if (target.x > x) image_xscale = visual_scale; else image_xscale = -visual_scale;

alarm[0] = irandom_range(jumpTime / 2, jumpTime);
