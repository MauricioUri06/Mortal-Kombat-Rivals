if (activo) anim += 8 / game_get_speed(gamespeed_fps);
curar_fx = max(0, curar_fx - 1);
if (usado) exit; // ya se agarro: no vuelve a curar

var _p = noone;
if (instance_exists(o_control)) _p = o_control.player;
if (!instance_exists(_p)) exit;
if (_p.dead) exit;

if (place_meeting(x, y, _p)) {
    // Primera vez: cura y guarda punto de reaparicion
    usado = true;
    c_sfx(snd_checkpoint, 0.8, 0);
    array_push(global.checkpoints_usados, clave);
    _p.hp = _p.hpMax;
    with (o_checkpoint) activo = false;
    activo = true;
    anim = 0;
    curar_fx = 45;
    global.checkpoint_activo = true;
    global.checkpoint_x = x;
    global.checkpoint_y = y;
}
