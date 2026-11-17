global.debug_hitboxes = false;
global.test_mode = false;
for (var _arg = 1; _arg <= parameter_count(); _arg++) {
    if (parameter_string(_arg) == "--self-test") global.test_mode = true;
}
// El azar del jefe cambia en cada partida; las pruebas usan siempre la misma semilla.
if (!global.test_mode) randomise();
self_test_frame = 0;
player_test_frame = -1;
main_menu_open = !global.test_mode;
menu_play = { left: 534, top: 438, right: 746, bottom: 494 };
menu_play_hovered = false;
match_menu = undefined;
match_menu_frozen = false;
match_menu_frame = -1;
match_menu_action = MatchMenuAction.none;
match_menu_choice = 0;
match_menu_hover = -1;
match_menu_buttons = { left: 510, right: 770, height: 42, spacing: 52 };
selecting = true;
selected_character = 0;
player = noone;
boss = noone;
baraka = noone;
goro = noone;
global.test_passes = 0;
global.test_failed = false;
display_set_gui_size(1280, 720);
gpu_set_texfilter(false);
window_set_caption("Mortal Kombat Rivals - Sub-Zero y Scorpion");
