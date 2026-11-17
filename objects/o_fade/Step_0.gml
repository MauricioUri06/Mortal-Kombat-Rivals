var _paso = 1 / (duracion * game_get_speed(gamespeed_fps));
if (estado == "oscurecer") {
    // El jugador se queda quieto mientras se oscurece
    if (instance_exists(o_control)) {
        var _p = o_control.player;
        if (instance_exists(_p)) { _p.input_enabled = false; _p.xSpeed = 0; }
    }
    alpha = min(1, alpha + _paso);
    if (alpha >= 1) {
        estado = "cambiando";
        c_transicion_cambiar(destino);
    }
} else if (estado == "aclarar") {
    alpha = max(0, alpha - _paso);
    if (alpha <= 0) instance_destroy();
}
