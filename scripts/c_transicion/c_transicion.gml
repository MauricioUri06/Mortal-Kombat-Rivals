/// Transicion entre cuartos con fundido a negro.

/// Empieza la transicion (si no hay otra en curso). _destino = -1: cuarto siguiente.
function c_transicion_iniciar(_destino) {
    if (instance_exists(o_fade)) exit;
    var _f = instance_create_depth(0, 0, -15000, o_fade);
    _f.destino = _destino;
}

/// La llama o_fade con la pantalla ya negra.
function c_transicion_cambiar(_destino) {
    var _sig = _destino;
    if (_sig == -1) _sig = room_next(room);
    // Nivel nuevo: se olvidan los checkpoints del anterior y se aparece en su o_spawn_player.
    global.checkpoint_activo = false;
    global.checkpoints_usados = [];
    if (_sig == -1) {
        // No hay mas cuartos: vuelve al primero y al selector.
        global.selected_character = -1;
        room_goto(room_first);
    } else {
        // Mismo personaje en el cuarto siguiente.
        if (instance_exists(o_control)) global.selected_character = o_control.selected_character;
        room_goto(_sig);
    }
}
