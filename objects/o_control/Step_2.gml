if (main_menu_open || selecting || match_menu_frozen) exit;
if (saliendo || instance_exists(o_fade)) exit; // ya eligio una opcion y se esta yendo
if (!instance_exists(player) || !instance_exists(boss)) exit;

var _player_dead = player.dead;
var _boss_dead = boss.dead;
if (!_player_dead && !_boss_dead) exit;
// Con un solo ganador, primero el fatality y despues el menu
if (_player_dead != _boss_dead) {
    if (!c_fatality_step(_boss_dead ? player : boss, _boss_dead ? boss : player)) exit;
}

var _title = "EMPATE";
var _subtitle = "DOBLE KO";
var _accent = make_colour_rgb(203, 188, 163);
if (_player_dead && !_boss_dead) {
    _title = "DERROTA";
    _subtitle = "GANA " + boss.character_name;
    _accent = make_colour_rgb(221, 110, 100);
} else if (_boss_dead && !_player_dead) {
    _title = "VICTORIA";
    _subtitle = "GANA " + player.character_name;
    _accent = make_colour_rgb(245, 195, 116);
}

if (_boss_dead && !_player_dead) c_sfx(snd_victory, 1, 0); else c_sfx(snd_defeat, 1, 0);
// Tras el fatality: pantalla de victoria del ganador con un solo boton
if (fatality_fase == 5) {
    var _winner = _boss_dead ? player : boss;
    c_match_menu_open({
        screen: _winner.projectile_object == o_iceball ? s_victory_sz : s_victory_sc,
        button: _winner.projectile_object == o_iceball ? s_btn_again_sz : s_btn_again_sc,
        buttons: { left: 440, right: 840, height: 97, spacing: 0 }, // area del boton de imagen
        title: "", subtitle: "", hint: "",
        accent: make_colour_rgb(245, 195, 116),
        top: 590,
        escape_action: MatchMenuAction.select_fighter,
        options: [{ label: "JUGAR DE NUEVO", action: MatchMenuAction.select_fighter }] // partida nueva desde el selector
    });
    exit;
}
c_match_menu_open({
    title: _title,
    subtitle: _subtitle,
    accent: _accent,
    top: 316,
    escape_action: MatchMenuAction.select_fighter,
    hint: "Flechas   Enter: elegir   Esc: selector",
    options: [
        { label: "REVANCHA", action: MatchMenuAction.restart },
        { label: "ELEGIR LUCHADOR", action: MatchMenuAction.select_fighter },
        { label: "VOLVER AL INICIO", action: MatchMenuAction.main_menu }
    ]
});
