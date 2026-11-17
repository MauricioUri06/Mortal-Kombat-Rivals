/// Fin del duelo: el perdedor agacha la cabeza, el ganador camina
/// hasta la distancia justa y hace su fatality; luego sale FATALITY.
/// Se llama desde o_control y devuelve true cuando ya puede abrir el menu.
function c_fatality_step(_win, _lose) {
    // Si cayo al vacio u otra muerte sin derrota, menu directo
    if (_lose.state != "defeat") return true;
    var _fps = game_get_speed(gamespeed_fps);
    fatality_timer++;
    switch (fatality_fase) {
        case 0:
            // El perdedor mira al ganador mientras agacha la cabeza
            if (fatality_timer == 1) _lose.right = _win.x > _lose.x;
            if (fatality_timer < _fps) return false;
            with (o_projectile) instance_destroy();
            var _dir = sign(_lose.x - _win.x);
            if (_dir == 0) _dir = 1;
            var _tx = _lose.x - _dir * _win.fatality_distance;
            // Sin espacio de ese lado se pone del otro
            if (_tx < 24 || _tx > room_width - 24) _tx = _lose.x + _dir * _win.fatality_distance;
            with (_win) {
                input_enabled = false;
                frozen_timer = 0;
                hitstun = 0;
                invi = 0;
                cine = "walk";
                cine_x = _tx;
                cine_timer = 0;
            }
            fatality_fase = 1;
            fatality_timer = 0;
        break;
        case 1:
            // Camina solo hasta quedar en su sitio
            if (_win.cine == "ready") {
                _win.right = _lose.x > _win.x;
                _lose.right = !_win.right;
                fatality_fase = 2;
                fatality_timer = 0;
            }
        break;
        case 2:
            // Pausa corta y la escena reemplaza a los dos luchadores
            if (fatality_timer >= 0.4 * _fps) {
                _win.cine = "fatality";
                _win.cine_frame = 0;
                _lose.visible = false;
                fatality_fase = 3;
                fatality_timer = 0;
            }
        break;
        case 3:
            // Ocho escenas a cuatro por segundo, la ultima se queda
            _win.cine_frame = min(fatality_timer / _fps * 4, sprite_get_number(_win.sprites.fatality) - 1);
            if (fatality_timer >= 2.6 * _fps) {
                fatality_fase = 4;
                fatality_timer = 0;
            }
        break;
        case 4:
            // FATALITY en medio de la pantalla (lo dibuja Draw GUI) y a los 3 s la victoria
            if (fatality_timer >= 3 * _fps) {
                fatality_fase = 5;
                return true;
            }
        break;
        default:
            return true;
    }
    return false;
}
