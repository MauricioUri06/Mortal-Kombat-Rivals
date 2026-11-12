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
        case "punch": anim_sprite = sprites.punch; anim_fps = 20; break;
        case "ranged": anim_sprite = sprites.ranged; anim_fps = 18; break;
        case "slide": anim_sprite = sprites.slide; anim_fps = 18; break;
        case "hurt": anim_sprite = sprites.hurt; anim_fps = 20; break;
        case "death": anim_sprite = sprites.death; anim_fps = 12; break;
    }
    sprite_index = anim_sprite;
    image_index = 0;
}
