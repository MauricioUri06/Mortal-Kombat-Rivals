if (!instance_exists(owner)) { instance_destroy(); exit; }
life--;
if (life <= 0 || x < -100 || x > room_width + 100) { instance_destroy(); exit; }
// Avanza de a un pixel para no atravesar
for (var _step = 0; _step < spd; _step++) {
    if (max_range >= 0 && (travel_distance >= max_range ||
        point_distance(owner.x + facing * anchor_x, owner.y + anchor_y, x + facing, y) > max_range)) {
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
            if (c_fighter_hit(_target, dmg, owner, kind, facing) && kind == "spear") c_sfx_cadena();
            // Tambien se consume contra un rival invulnerable
            instance_destroy();
            exit;
        }
    }
    var _enemy = instance_place(x, y, o_enemy);
    if (_enemy != noone) {
        if (_enemy.team != team && _enemy.hp > 0) {
            _enemy.hp -= dmg;
            _enemy.hit_flash = 8;
            c_sfx(kind == "ice" ? snd_freeze : snd_hit, 0.9);
            if (kind == "spear") c_sfx_cadena();
            instance_destroy();
            exit;
        }
    }
}
