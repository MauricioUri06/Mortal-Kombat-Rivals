// Muerte, como o_enemy_body ---------

if (hp <= 0) {
	instance_destroy();
	exit;
}

hit_flash = max(0, hit_flash - 1);

// Cae hasta la superficie del nivel, igual que Goro.
if (y > room_height + 200) { instance_destroy(); exit; }
if (!place_meeting(x, y + 1, o_terrain)) {
    ySpeed = min(ySpeed + grav, fallMax);
    var _fall = ySpeed;
    while (_fall > 0 && !place_meeting(x, y + 1, o_terrain)) {
        y += min(1, _fall);
        _fall -= 1;
    }
    if (!place_meeting(x, y + 1, o_terrain)) exit;
}
ySpeed = 0;

anim += 1 / 5; // 12 cuadros por segundo

// Mira al jugador si esta en su misma linea --

if (state == "idle" && instance_exists(target)) {
	if (!target.dead && abs(target.y - y) <= range_y && abs(target.x - x) <= xrange) {
		if (target.x > x) image_xscale = visual_scale; else image_xscale = -visual_scale;
	}
}

// Lanzamiento: el abanico sale con el brazo extendido --

if (state == "throw") {
	if (!thrown && anim >= 4) {
		thrown = true;
		var _dir = sign(image_xscale);
		var _fan = instance_create_layer(x + 30 * _dir, y, "att", o_fan);
		_fan.y = y - _fan.height;
		_fan.owner = id;
		_fan.team = team;
		_fan.facing = _dir;
		_fan.image_xscale = _fan.scale * _dir;
		_fan.image_yscale = _fan.scale;
	}
	if (anim >= 8) {
		state = "idle";
		anim = 0;
	}
}
