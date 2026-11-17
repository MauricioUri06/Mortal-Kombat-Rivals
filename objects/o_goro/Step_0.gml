// Muerte, como o_enemy_body ---------

if (hp <= 0) {
	instance_destroy();
	exit;
}

// Colocado a mano en la room: busca al jugador cuando aparece.
if (!instance_exists(target) && instance_exists(o_control)) target = o_control.player;
hit_flash = max(0, hit_flash - 1);

// Gravedad: si lo colocaste en el aire, cae hasta el suelo antes de patrullar.
if (y > room_height + 200) { instance_destroy(); exit; }
// (o_terrain incluye o_solid y o_nube: tambien se para sobre las nubes)
if (!place_meeting(x, y + 1, o_terrain)) {
	ySpeed = min(ySpeed + grav, fallMax);
	var _fall = ySpeed;
	while (_fall > 0 && !place_meeting(x, y + 1, o_terrain)) { y += min(1, _fall); _fall -= 1; }
	if (!place_meeting(x, y + 1, o_terrain)) exit;
}
ySpeed = 0;

// Fuera de rango: se queda quieto (guarda su velocidad para seguir despues).
// Si esta embistiendo, termina la embestida antes de quedarse quieto.
var _en_rango = instance_exists(target);
if (_en_rango) _en_rango = !target.dead && abs(target.x - x) <= xrange && abs(target.y - y) <= yrange;
if (!_en_rango && state != "tackle") {
	if (hspeed != 0) { pausa_hspeed = hspeed; hspeed = 0; }
	exit;
}
if (hspeed == 0 && pausa_hspeed != 0) { hspeed = pausa_hspeed; pausa_hspeed = 0; }

if (state == "tackle") anim += 1 / 4; else anim += 1 / 6;

// Delante: pared, final del mapa o borde del que caeria --

var _dir = sign(image_xscale);
var _ahead = max(xCheck, abs(hspeed) + 2);
var _blocked = place_meeting(x + _dir * _ahead, y, o_solid)
	|| x + _dir * _ahead < 24 || x + _dir * _ahead > room_width - 24
	|| collision_rectangle(x + _dir * 18, y, x + _dir * 20, y + 2, o_terrain, 0, 1) == noone; // borde: sin suelo ni nube delante

switch (state) {
	case "walk":
		// Ve al jugador en su linea (delante o detras) y sin pared en medio: se gira y embiste.
		if (instance_exists(target)) {
			if (!target.dead && abs(target.y - y) <= range_y && target.x != x
			&& collision_line(x, y - 40, target.x, y - 40, o_solid, 0, 1) == noone) {
				var _to = sign(target.x - x);
				if (_to != _dir) {
					image_xscale = abs(image_xscale) * _to; // se da la vuelta hacia el jugador
					_dir = _to;
				}
				state = "tackle";
				anim = 0;
				hspeed = tackleSpeed * _dir;
			}
		}
		// Si no, da la vuelta como o_enemy_walker.
		if (state == "walk" && _blocked) c_flip();
	break;

	case "tackle":
		// Sigue hasta golpear al jugador o chocar con algo; despues queda confundido.
		var _hit_player = false;
		if (instance_exists(target)) _hit_player = place_meeting(x, y, target);
		if (_hit_player) c_fighter_hit(target, dmg, id, "goro", _dir);
		if (_hit_player || _blocked) {
			state = "dazed";
			anim = 0;
			hspeed = 0;
			alarm[0] = dazedTime * game_get_speed(gamespeed_fps);
		}
	break;
}
