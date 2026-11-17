randomise();
main_menu_open = false; // se decide mas abajo segun la partida
menu_play = { left: 534, top: 438, right: 746, bottom: 494 };
menu_play_hovered = false;
menu_salir = { left: 534, top: 512, right: 746, bottom: 568 };
menu_salir_hovered = false;
menu_opcion = 0; // boton elegido: cero jugar, uno salir
match_menu = undefined;
match_menu_frozen = false;
match_menu_frame = -1;
match_menu_action = MatchMenuAction.none;
match_menu_choice = 0;
match_menu_hover = -1;
match_menu_buttons = { left: 510, right: 770, height: 42, spacing: 52 };
selecting = true;
// Al reiniciar se empieza con el mismo personaje
if (!variable_global_exists("selected_character")) global.selected_character = -1;
pending_start = global.selected_character;
// Menu principal solo aparece en partida nueva
if (!variable_global_exists("ir_al_selector")) global.ir_al_selector = false;
main_menu_open = pending_start < 0 && !global.ir_al_selector;
global.ir_al_selector = false;
saliendo = false; // true si ya se eligio salir del nivel
if (!variable_global_exists("checkpoint_activo")) global.checkpoint_activo = false;
if (!variable_global_exists("checkpoint_x")) { global.checkpoint_x = 0; global.checkpoint_y = 0; }
if (!variable_global_exists("checkpoints_usados")) global.checkpoints_usados = [];
if (!variable_global_exists("dash_desbloqueado")) global.dash_desbloqueado = false;
if (global.selected_character < 0) { // partida nueva: se borra todo el progreso
    global.checkpoint_activo = false;
    global.checkpoints_usados = [];
    global.dash_desbloqueado = false;
}
death_timer = 0;
// Logo de Gaira Games solo la primera vez
if (!variable_global_exists("splash_visto")) global.splash_visto = false;
if (!global.splash_visto) {
    global.splash_visto = true;
    window_set_fullscreen(true); // pantalla completa al abrir el juego
    instance_create_depth(0, 0, -15500, o_splash); // menos de -16000 no se llega a dibujar
}
c_fondo_crear(); // crea el fondo del nivel que sigue la camara
selected_character = 0;
player = noone;
boss = noone;
baraka = noone;
goro = noone;
display_set_gui_size(1280, 720);
gpu_set_texfilter(false);
window_set_caption("Mortal Kombat Rivals - Sub-Zero y Scorpion");
