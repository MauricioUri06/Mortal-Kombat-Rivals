/// Cambia de estado sin reiniciar la animacion cada Step.
function c_fighter_state(_next) {
    if (state == _next && anim_sprite != -1) return;
    state = _next;
    state_tick = 0;
    action_fired = false;
    anim_frame = 0;
    anim_done = false;
    anim_loop = false;
    switch (state) {
        case "stand": anim_sprite = sprites.stand; anim_fps = 8; anim_loop = true; break;
        case "run": anim_sprite = sprites.run; anim_fps = 14; anim_loop = true; break;
        case "jump_start": anim_sprite = sprites.jump_start; anim_fps = 24; break;
        case "jump": anim_sprite = sprites.jump; anim_fps = 16; break;
        case "fall": anim_sprite = sprites.fall; anim_fps = 16; break;
        case "land": anim_sprite = sprites.land; anim_fps = 16; break;
        case "punch": anim_sprite = sprites.punch; anim_fps = 20 * attack_speed; break;
        case "kick": anim_sprite = sprites.kick; anim_fps = 14 * attack_speed; break;
        case "crouch": anim_sprite = sprites.crouch; anim_fps = 28; break;
        case "ranged": anim_sprite = sprites.ranged; anim_fps = 18 * attack_speed; break;
        case "slide": anim_sprite = sprites.slide; anim_fps = 18; break;
        case "hurt": anim_sprite = sprites.hurt; anim_fps = 20; break;
        case "wall":
            // Agarrado a la pared: cuadros 0-1 de la animacion de wall jump (se alternan en o_fighter).
            anim_sprite = variable_struct_exists(sprites, "wall") ? sprites.wall : sprites.fall;
            anim_fps = 0;
        break;
        case "wall_jump":
            // Impulso desde la pared: cuadros 2-7 de la animacion de wall jump.
            anim_sprite = variable_struct_exists(sprites, "wall") ? sprites.wall : sprites.jump;
            anim_fps = 16;
            anim_frame = variable_struct_exists(sprites, "wall") ? 2 : 0;
        break;
        case "hook":
            // Animacion del gancho; el cuadro lo elige o_fighter segun el avance del jalon.
            anim_sprite = variable_struct_exists(sprites, "hook") ? sprites.hook : sprites.ranged;
            anim_fps = 0;
            anim_frame = variable_struct_exists(sprites, "hook") ? 0 : min(4, sprite_get_number(anim_sprite) - 1);
        break;
        case "death": anim_sprite = sprites.death; anim_fps = 12; break;
    }
    sprite_index = anim_sprite;
    image_index = floor(anim_frame);
}
