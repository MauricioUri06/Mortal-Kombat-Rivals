if (!is_undefined(match_menu) || match_menu_action == MatchMenuAction.none) exit;

// Las instancias se reactivaron al terminar el Draw GUI del frame anterior.
c_match_menu_free_frame();
var _action = match_menu_action;
match_menu_action = MatchMenuAction.none;

switch (_action) {
    case MatchMenuAction.restart:
        c_player_start(selected_character);
        break;
    case MatchMenuAction.select_fighter:
    case MatchMenuAction.main_menu:
        c_player_clear();
        selected_character = 0;
        selecting = true;
        main_menu_open = _action == MatchMenuAction.main_menu;
        global.debug_hitboxes = false;
        break;
}
