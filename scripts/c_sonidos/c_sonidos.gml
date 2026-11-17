/// Efectos de sonido y musica de todo el juego

/// Reproduce un efecto con pequena variacion de tono
function c_sfx(_snd, _gain = 1, _pitch_var = 0.05) {
    var _pitch = 1 + random_range(-_pitch_var, _pitch_var);
    return audio_play_sound(_snd, 5, false, _gain, 0, _pitch);
}

/// Voz de la cadena de Scorpion, una a la vez
function c_sfx_cadena() {
    if (!variable_global_exists("sfx_cadena")) global.sfx_cadena = -1;
    if (global.sfx_cadena >= 0 && audio_is_playing(global.sfx_cadena)) audio_stop_sound(global.sfx_cadena);
    global.sfx_cadena = audio_play_sound(snd_scorpion_chain, 8, false);
}

// Musica de fondo de cada uno de los niveles
#macro MUSIC_GAIN 0.6 // volumen general de la musica de los niveles
#macro MUSIC_GAIN_MENU 0.35 // fraccion del volumen con un menu encima

/// Pista de cada room, nombrada directo para compilar
function c_musica_de_room() {
    switch (room_get_name(room)) {
        case "Nivel1": return mus_nivel1;
        case "Nivel2": return mus_nivel2;
        case "Nivel3": return mus_arena;
    }
    return -1;
}

/// Llamar cada Step desde o_control con el estado
/// Con un menu encima la musica solo baja
/// Al reiniciar el nivel la pista sigue sonando
function c_musica_nivel_update(_jugando, _menu_encima) {
    if (!variable_global_exists("level_music")) {
        global.level_music = -1;
        global.level_music_snd = -1;
        global.level_music_gain = 0;
    }
    var _snd = _jugando ? c_musica_de_room() : -1;
    var _sonando = global.level_music != -1 && audio_is_playing(global.level_music);
    if (global.level_music_snd != _snd || (_snd != -1 && !_sonando)) {
        if (global.level_music != -1) audio_stop_sound(global.level_music);
        global.level_music = -1;
        global.level_music_snd = _snd;
        global.level_music_gain = 0;
        if (_snd != -1) global.level_music = audio_play_sound(_snd, 20, true, 0); // la musica entra con un fundido suave
    }
    if (global.level_music == -1) exit;
    var _objetivo = _menu_encima ? MUSIC_GAIN * MUSIC_GAIN_MENU : MUSIC_GAIN;
    if (global.level_music_gain != _objetivo) {
        // Fundido largo al empezar, corto con los menus
        audio_sound_gain(global.level_music, _objetivo, global.level_music_gain == 0 ? 1500 : 400);
        global.level_music_gain = _objetivo;
    }
}
