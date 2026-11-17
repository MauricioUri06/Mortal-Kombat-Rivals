if (!instance_exists(o_control)) exit;
var _p = o_control.player;
if (!instance_exists(_p)) exit;
if (_p.dead) exit;
if (place_meeting(x, y, _p)) {
    var _dir = sign(_p.x - (bbox_left + bbox_right) / 2);
    if (_dir == 0) _dir = 1;
    // c_fighter_hit respeta la invulnerabilidad del jugador
    if (c_fighter_hit(_p, dmg, id, "trampa", _dir)) {
        _p.ySpeed = -empuje;
        _p.ground = false;
    }
}
