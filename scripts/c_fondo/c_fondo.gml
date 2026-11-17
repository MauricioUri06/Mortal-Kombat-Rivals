/// Fondo que sigue a la camara: siempre cubre toda la pantalla aunque
/// la imagen sea mas chica que la room, y se desplaza un poco (parallax)
/// segun el avance del jugador por el nivel.

/// Que sprite de fondo usa cada room.
/// Se nombran directo (no como texto) para que GameMaker no los quite al compilar
/// ("Remove unused assets" esta activado en Game Options).
/// Cuando existan s_background_2 / s_background_3, cambia el -1 por el sprite.
function c_fondo_sprite_de_room() {
    switch (room_get_name(room)) {
        case "Nivel1": return s_background_1;
        case "Nivel2": return -1; // s_background_2
        case "Arena":  return -1; // s_background_3
    }
    return -1;
}

/// Crea el fondo de la room actual, si su sprite existe. Llamar desde o_control.
function c_fondo_crear() {
    var _spr = c_fondo_sprite_de_room();
    if (_spr < 0 || !sprite_exists(_spr)) exit;
    // Capa propia justo delante de la capa de fondo (Background) de la room,
    // asi queda detras de TODAS las capas de tiles e instancias, sin importar su profundidad.
    var _depth = 10000;
    var _capas = layer_get_all();
    var _hay_fondo = false;
    for (var _i = 0; _i < array_length(_capas); _i++) {
        if (layer_background_get_id(_capas[_i]) != -1) {
            var _d = layer_get_depth(_capas[_i]);
            if (!_hay_fondo || _d < _depth) { _depth = _d; _hay_fondo = true; }
        }
    }
    if (_hay_fondo) _depth -= 1;
    var _layer = layer_create(_depth, "fondo_dinamico");
    var _f = instance_create_layer(0, 0, _layer, o_fondo);
    _f.sprite_index = _spr;
}
