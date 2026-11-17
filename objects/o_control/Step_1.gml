if (!is_undefined(match_menu) || match_menu_action == MatchMenuAction.none) exit;

// Las instancias se reactivaron al terminar el Draw GUI del frame anterior.
c_match_menu_free_frame();
var _action = match_menu_action;
match_menu_action = MatchMenuAction.none;

switch (_action) {
    case MatchMenuAction.restart:
        global.selected_character = selected_character;
        room_restart();
        break;
    case MatchMenuAction.select_fighter:
        c_player_clear();
        selected_character = 0;
        selecting = true;
        main_menu_open = false;
        global.debug_hitboxes = false;
        break;
    case MatchMenuAction.main_menu:
        global.selected_character = -1;
        global.checkpoint_activo = false;
        room_restart();
        break;
}
