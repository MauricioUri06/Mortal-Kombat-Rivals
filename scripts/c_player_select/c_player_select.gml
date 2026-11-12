/// Selector inicial: solo crea el personaje elegido.
/// Se ejecuta en el contexto de o_control.
function c_player_start(_choice) {
    with (o_att) instance_destroy();
    with (o_fighter) instance_destroy();
    selected_character = clamp(_choice, 0, 1);
    var _player_object = selected_character == 0 ? o_player_sz : o_player_sc;
    player = instance_create_layer(380, 592, "Instances", _player_object);
    selecting = false;
}

function c_player_select_input(_left, _right, _confirm) {
    if (!selecting) exit;
    if (_left) selected_character = 0;
    if (_right) selected_character = 1;
    if (_confirm) {
        // Espacio confirma el menu sin iniciar un salto en ese mismo frame.
        keyboard_clear(vk_space);
        c_player_start(selected_character);
    }
}
