if (!instance_exists(owner)) { instance_destroy(); exit; }
life--;
if (life <= 0 || x < -100 || x > room_width + 100) { instance_destroy(); exit; }
// Barrido por pasos de un pixel para respetar paredes y objetivos a alta velocidad.
for (var _step = 0; _step < spd; _step++) {
    if (max_range >= 0 && (travel_distance >= max_range ||
        point_distance(owner.x + facing * 30, owner.y - 53, x + facing, y) > max_range)) {
        instance_destroy();
        exit;
    }
    x += facing;
    travel_distance++;
    if (place_meeting(x, y, o_solid)) { instance_destroy(); exit; }
    for (var _i = 0; _i < instance_number(o_fighter); _i++) {
        var _target = instance_find(o_fighter, _i);
        if (_target.player_number == team || _target.dead) continue;
        if (place_meeting(x, y, _target)) {
            c_fighter_hit(_target, dmg, owner, kind, facing);
            // Tambien se consume contra un rival temporalmente invulnerable.
            instance_destroy();
            exit;
        }
    }
}
