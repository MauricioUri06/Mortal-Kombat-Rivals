// Checkpoint de un solo uso: guarda punto y cura
// Cuadro cero apagado, cuadros uno a tres llama
if (!variable_global_exists("checkpoint_activo")) global.checkpoint_activo = false;
if (!variable_global_exists("checkpoints_usados")) global.checkpoints_usados = [];
clave = string(x) + "_" + string(y);
// Ya usado en esta partida, aunque muera
usado = array_contains(global.checkpoints_usados, clave);
// El ultimo checkpoint agarrado sigue encendido
activo = global.checkpoint_activo && global.checkpoint_x == x && global.checkpoint_y == y;
anim = 0;
curar_fx = 0; // frames que dura el aviso de vida
image_speed = 0;
