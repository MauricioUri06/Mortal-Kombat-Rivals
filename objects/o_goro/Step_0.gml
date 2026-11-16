// Muerte, como o_enemy_body ---------

if (hp <= 0) {
	instance_destroy();
	exit;
}

hit_flash = max(0, hit_flash - 1);
if (state == "tackle") anim += 1 / 4; else anim += 1 / 6;

// Delante: pared, final del mapa o borde del que caeria --

var _dir = sign(image_xscale);
var _ahead = max(xCheck, abs(hspeed) + 2);
var _blocked = place_meeting(x + _dir * _ahead, y, o_solid)
	|| x + _dir * _ahead < 24 || x + _dir * _ahead > room_width - 24
	|| collision_rectangle(x + _dir * 18, y, x + _dir * 20, y + 2, o_solid, 0, 1) == noone;

switch (state) {
	case "walk":
		// Ve al jugador en su linea, delante de el y sin pared en medio: embiste.
		if (instance_exists(target)) {
			if (!target.dead && abs(target.y - y) <= range_y && sign(target.x - x) == _dir
			&& collision_line(x, y - 40, target.x, y - 40, o_solid, 0, 1) == noone) {
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
