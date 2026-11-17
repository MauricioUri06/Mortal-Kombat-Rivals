/// Transiciones entre cuartos con fundido a negro

/// Empieza la transicion si no hay otra en curso
/// Destino: menos uno siguiente, menos dos menu, menos tres selector
function c_transicion_iniciar(_destino) {
    if (instance_exists(o_fade)) exit;
    c_sfx(snd_transition, 0.8, 0);
    var _f = instance_create_depth(0, 0, -15000, o_fade);
    _f.destino = _destino;
}

/// La llama o_fade con la pantalla ya negra
function c_transicion_cambiar(_destino) {
    if (_destino == -2 || _destino == -3) {
        global.ir_al_selector = (_destino == -3); // con menos tres se salta el menu principal
        global.selected_character = -1;
        global.checkpoint_activo = false;
        global.checkpoints_usados = [];
        global.dash_desbloqueado = false;
        room_goto(room_first);
        exit;
    }
    var _sig = _destino;
    if (_sig == -1) _sig = room_next(room);
    // Nivel nuevo: se borran los checkpoints anteriores
    global.checkpoint_activo = false;
    global.checkpoints_usados = [];
    if (_sig == -1) {
        // Sin mas cuartos vuelve al primero y al menu
        global.selected_character = -1;
        room_goto(room_first);
    } else {
        // Mismo personaje en el siguiente cuarto del juego
        if (instance_exists(o_control)) global.selected_character = o_control.selected_character;
        room_goto(_sig);
    }
}

/// Reinicia la room sin perder el o_control
function c_reiniciar_room() {
    // Usa o_fade invisible que crea o_control si falta
    if (!instance_exists(o_fade)) {
        var _f = instance_create_depth(0, 0, -15000, o_fade);
        _f.estado = "cambiando";
        _f.alpha = 0;
    }
    room_restart();
}
