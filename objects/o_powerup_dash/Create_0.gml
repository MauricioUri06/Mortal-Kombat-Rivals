// Power-up: desbloquea el dash para toda la partida
if (!variable_global_exists("dash_desbloqueado")) global.dash_desbloqueado = false;
// Si ya se agarro, no vuelve a aparecer
if (global.dash_desbloqueado) { instance_destroy(); exit; }
base_y = y;
t = 0;
image_speed = 0;
