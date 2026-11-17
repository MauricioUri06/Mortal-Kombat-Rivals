if (global.test_mode || main_menu_open || selecting || match_menu_frozen) exit;
if (!instance_exists(player) || !instance_exists(boss)) exit;

var _player_dead = player.dead;
var _boss_dead = boss.dead;
if (!_player_dead && !_boss_dead) exit;

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
