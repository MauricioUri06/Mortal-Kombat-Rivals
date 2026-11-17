if (!is_undefined(match_menu) || match_menu_action == MatchMenuAction.none) exit;

// Las instancias ya se reactivaron tras el menu
c_match_menu_free_frame();
var _action = match_menu_action;
match_menu_action = MatchMenuAction.none;

switch (_action) {
    case MatchMenuAction.restart:
        // Reinicia el nivel con el mismo personaje elegido
        global.selected_character = selected_character;
        c_reiniciar_room();
        break;
    case MatchMenuAction.select_fighter:
        // Partida nueva con fundido, directo al selector
        saliendo = true;
        c_transicion_iniciar(-3);
        break;
    case MatchMenuAction.main_menu:
        // Partida nueva con fundido, vuelve al menu principal
        saliendo = true;
        c_transicion_iniciar(-2);
        break;
}
