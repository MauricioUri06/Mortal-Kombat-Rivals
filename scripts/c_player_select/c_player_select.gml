/// Selector inicial: crea el personaje elegido, enfrente al otro como jefe, y a los enemigos Baraka y Goro.
/// Se ejecuta en el contexto de o_control.
function c_player_start(_choice) {
    with (o_att) instance_destroy();
    with (o_fighter) instance_destroy();
    with (o_enemy) instance_destroy();
    selected_character = clamp(_choice, 0, 1);
    var _player_object = selected_character == 0 ? o_player_sz : o_player_sc;
    var _boss_object = selected_character == 0 ? o_boss_sc : o_boss_sz;
    player = instance_create_layer(380, 592, "Instances", _player_object);
    boss = instance_create_layer(room_width - 380, 592, "Instances", _boss_object);
    boss.target = player;
    // Aparece un poco por encima del suelo y cae, como los enemigos de la referencia.
    baraka = instance_create_layer(room_width / 2, 560, "Instances", o_baraka);
    baraka.target = player;
    // Goro patrulla el suelo cerca del borde derecho.
    goro = instance_create_layer(room_width - 160, 591, "Instances", o_goro);
    goro.target = player;
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
