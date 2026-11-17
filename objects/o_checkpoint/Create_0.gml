// Checkpoint: se agarra UNA sola vez. Al tocarlo se enciende, guarda el punto de
// reaparicion y cura al jugador. Despues ya no se puede volver a agarrar ni cura.
// Cuadro 0 = apagado, cuadros 1-3 = llama.
if (!variable_global_exists("checkpoint_activo")) global.checkpoint_activo = false;
if (!variable_global_exists("checkpoints_usados")) global.checkpoints_usados = [];
clave = string(x) + "_" + string(y);
// Ya usado en esta partida (sigue asi aunque el jugador muera y reaparezca).
usado = array_contains(global.checkpoints_usados, clave);
// Si es el ultimo checkpoint que se agarro, sigue encendido despues de reaparecer.
activo = global.checkpoint_activo && global.checkpoint_x == x && global.checkpoint_y == y;
anim = 0;
curar_fx = 0;     // frames del aviso "+VIDA"
image_speed = 0;
