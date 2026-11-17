t += 1;
y = base_y + sin(t / 12) * 4; // flota subiendo y bajando sin parar
if (!instance_exists(o_control)) exit;
var _p = o_control.player;
if (!instance_exists(_p)) exit;
if (_p.dead) exit;
if (place_meeting(x, y, _p)) {
    global.dash_desbloqueado = true;
    c_sfx(snd_powerup, 0.8, 0);
    var _a = instance_create_depth(0, 0, -14000, o_aviso);
    _a.texto = "DASH DESBLOQUEADO";
    _a.subtexto = "Presiona E para hacer un dash";
    instance_destroy();
}
