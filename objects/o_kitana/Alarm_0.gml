/// @description Lanzar abanico
// Cada 3 segundos si el jugador esta en su linea; si no, vuelve a mirar en un momento.

var _in_line = false;
if (instance_exists(target)) _in_line = ySpeed == 0 && !target.dead && abs(target.y - y) <= range_y && abs(target.x - x) <= xrange;

if (_in_line && state == "idle") {
	state = "throw";
	anim = 0;
	thrown = false;
	alarm[0] = throwTime * game_get_speed(gamespeed_fps);
} else {
	alarm[0] = 10;
}
