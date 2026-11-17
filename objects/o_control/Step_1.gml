if (!is_undefined(match_menu) || match_menu_action == MatchMenuAction.none) exit;

// Las instancias se reactivaron al terminar el Draw GUI del frame anterior.
c_match_menu_free_frame();
var _action = match_menu_action;
match_menu_action = MatchMenuAction.none;

switch (_action) {
    case MatchMenuAction.restart:
        // Reinicia el nivel (enemigos en su lugar) en el ultimo checkpoint, con el mismo personaje.
        global.selected_character = selected_character;
        room_restart();
        break;
    case MatchMenuAction.select_fighter:
    case MatchMenuAction.main_menu:
        // Partida nueva: se olvidan personaje y checkpoints y se vuelve al primer nivel.
        global.selected_character = -1;
        global.checkpoint_activo = false;
        global.checkpoints_usados = [];
        global.debug_hitboxes = false;
        room_goto(room_first);
        break;
}
