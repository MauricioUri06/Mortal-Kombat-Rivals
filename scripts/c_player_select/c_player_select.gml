/// Selector inicial: crea el personaje elegido, enfrente al otro como jefe, y a los enemigos Baraka y Goro.
/// Se ejecuta en el contexto de o_control.
function c_player_start(_choice) {
    with (o_att) instance_destroy();
    with (o_fighter) instance_destroy();
    selected_character = clamp(_choice, 0, 1);
    global.selected_character = selected_character;
    var _player_object = selected_character == 0 ? o_player_sz : o_player_sc;

    // El jugador aparece donde este el o_spawn_player de la room.
    var _sx = 160;
    var _sy = room_height - 64;
    if (global.checkpoint_activo) {
        // Reaparece en el ultimo checkpoint encendido.
        _sx = global.checkpoint_x;
        _sy = global.checkpoint_y;
    } else if (instance_exists(o_spawn_player)) {
        var _spawn = instance_find(o_spawn_player, 0);
        _sx = _spawn.x;
        _sy = _spawn.y;
    } else {
        show_debug_message("AVISO: falta o_spawn_player en la room; el jugador aparece en una posicion por defecto.");
    }
    if (!layer_exists("Instances")) layer_create(0, "Instances");
    player = instance_create_layer(_sx, _sy, "Instances", _player_object);
    with (player) {
        // Si el marcador quedo metido en el suelo, sube al jugador hasta quedar libre.
        var _n = 0;
        while (place_meeting(x, y, o_solid) && _n < 256) { y--; _n++; }
        spawn_x = x;
        spawn_y = y;
    }

    // Ya no se crean enemigos ni jefe automaticamente: se colocan a mano en la room.
    boss = noone;
    baraka = noone;
    goro = noone;
    with (o_enemy) target = other.player;

    // La camara sigue al jugador.
    camera_set_view_target(view_camera[0], player);
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
