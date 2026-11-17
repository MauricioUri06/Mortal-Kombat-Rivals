if (!activo) exit;
var _fps = game_get_speed(gamespeed_fps);

if (!desapareciendo) {
    // Se forma con la animacion y cuenta el tiempo
    if (anim < 3) anim = min(3, anim + 10 / _fps);
    timer++;
    if (timer >= duracion * _fps) {
        // Se rompe: deja de sostener y se deshace
        desapareciendo = true;
        anim = 3;
        c_sfx(snd_ice_break, 0.7);
        if (instance_exists(solido)) instance_destroy(solido);
        solido = noone;
    }
} else {
    anim -= fps_romper / _fps; // se deshace mas lento de lo que se forma
    if (anim <= 0) {
        activo = false;
        desapareciendo = false;
        anim = 0;
        timer = 0;
    }
}
