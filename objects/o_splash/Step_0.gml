t += 1 / game_get_speed(gamespeed_fps);
// Enter, Espacio o clic saltan el logo
var _salto = fade_in + espera;
if (t < _salto && (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left))) {
    t = _salto;
    keyboard_clear(vk_enter);
    keyboard_clear(vk_space);
    mouse_clear(mb_left);
}
if (t >= fade_in + espera + fade_out + menu_in) instance_destroy();
