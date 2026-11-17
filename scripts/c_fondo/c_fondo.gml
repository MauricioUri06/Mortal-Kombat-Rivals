/// Fondo que sigue a la camara y cubre la pantalla
/// Se desplaza un poco segun el avance del jugador

/// Sprite de fondo que usa cada una de las rooms
/// Nombrados directo para que no se quiten al compilar
/// Para un nivel nuevo agregar aqui su fondo
function c_fondo_sprite_de_room() {
    switch (room_get_name(room)) {
        case "Nivel1": return s_background_1;
        case "Nivel2": return s_background_2;
        case "Nivel3": return s_background_3;
    }
    return -1;
}

/// Crea el fondo de la room si existe
function c_fondo_crear() {
    var _spr = c_fondo_sprite_de_room();
    if (_spr < 0 || !sprite_exists(_spr)) exit;
    // Capa propia justo delante de la capa Background
    // Asi queda detras de todas las demas capas
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
