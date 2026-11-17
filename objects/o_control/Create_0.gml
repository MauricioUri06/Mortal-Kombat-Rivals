global.debug_hitboxes = false;
global.test_mode = false;
for (var _arg = 1; _arg <= parameter_count(); _arg++) {
    if (parameter_string(_arg) == "--self-test") global.test_mode = true;
}
// El azar del jefe cambia en cada partida; las pruebas usan siempre la misma semilla.
if (!global.test_mode) randomise();
self_test_frame = 0;
player_test_frame = -1;
main_menu_open = false; // se decide mas abajo
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
// Tras R (reiniciar) se vuelve a empezar directo con el mismo personaje.
if (!variable_global_exists("selected_character")) global.selected_character = -1;
pending_start = global.test_mode ? -1 : global.selected_character;
// El menu principal solo aparece en una partida nueva (no al reiniciar ni al cambiar de nivel).
main_menu_open = !global.test_mode && pending_start < 0;
if (!variable_global_exists("checkpoint_activo")) global.checkpoint_activo = false;
if (!variable_global_exists("checkpoint_x")) { global.checkpoint_x = 0; global.checkpoint_y = 0; }
if (!variable_global_exists("checkpoints_usados")) global.checkpoints_usados = [];
if (global.selected_character < 0) { // partida nueva
    global.checkpoint_activo = false;
    global.checkpoints_usados = [];
}
death_timer = 0;
c_fondo_crear(); // fondo del nivel que sigue a la camara
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
