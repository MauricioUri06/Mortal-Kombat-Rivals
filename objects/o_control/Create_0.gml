global.debug_hitboxes = false;
global.test_mode = false;
for (var _arg = 1; _arg <= parameter_count(); _arg++) {
    if (parameter_string(_arg) == "--self-test") global.test_mode = true;
}
// El azar del jefe cambia en cada partida; las pruebas usan siempre la misma semilla.
if (!global.test_mode) randomise();
self_test_frame = 0;
player_test_frame = -1;
selecting = true;
selected_character = 0;
player = noone;
boss = noone;
global.test_passes = 0;
global.test_failed = false;
display_set_gui_size(1280, 720);
gpu_set_texfilter(false);
window_set_caption("Mortal Kombat Rivals - Sub-Zero y Scorpion");
