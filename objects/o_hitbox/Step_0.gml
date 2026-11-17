if (!instance_exists(owner)) { instance_destroy(); exit; }
if (owner.dead || owner.state == "hurt" || owner.frozen_timer > 0) { instance_destroy(); exit; }
if (owner.state != kind) { instance_destroy(); exit; }
x = owner.x + facing * offset_x;
y = owner.y + offset_y;
for (var _i = 0; _i < instance_number(o_fighter); _i++) {
    var _target = instance_find(o_fighter, _i);
    if (_target.player_number == team || _target.dead) continue;
    var _already_hit = false;
    for (var _j = 0; _j < array_length(hit_targets); _j++) {
        if (hit_targets[_j] == _target) _already_hit = true;
    }
    if (_already_hit) continue;
    if (_target.bbox_right >= x - half_width && _target.bbox_left <= x + half_width
    && _target.bbox_bottom >= y - half_height && _target.bbox_top <= y + half_height) {
        if (c_fighter_hit(_target, dmg, owner, kind, facing)) array_push(hit_targets, _target);
    }
}
// Los enemigos reciben golpes del equipo contrario
for (var _k = 0; _k < instance_number(o_enemy); _k++) {
    var _enemy = instance_find(o_enemy, _k);
    if (_enemy.team == team || _enemy.hp <= 0 || array_contains(hit_targets, _enemy)) continue;
    if (_enemy.bbox_right >= x - half_width && _enemy.bbox_left <= x + half_width
    && _enemy.bbox_bottom >= y - half_height && _enemy.bbox_top <= y + half_height) {
        _enemy.hp -= dmg;
        _enemy.hit_flash = 8;
        c_sfx(snd_hit, 0.9);
        array_push(hit_targets, _enemy);
    }
}
life--;
if (life <= 0) instance_destroy();
