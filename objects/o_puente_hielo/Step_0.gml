if (!activo) exit;
var _fps = game_get_speed(gamespeed_fps);

if (!desapareciendo) {
    // Se forma (3 cuadros a 10 fps) y cuenta el tiempo.
    if (anim < 3) anim = min(3, anim + 10 / _fps);
    timer++;
    if (timer >= duracion * _fps) {
        // Se rompe: deja de ser solido y la animacion corre al reves.
        desapareciendo = true;
        anim = 3;
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
