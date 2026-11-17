if (!instance_exists(o_control)) exit;
var _p = o_control.player;
if (!instance_exists(_p)) exit;
if (_p.dead) exit;
if (place_meeting(x, y, _p)) c_transicion_iniciar(destino);
