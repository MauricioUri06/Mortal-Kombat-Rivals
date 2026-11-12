// Como en la referencia: entradas, movimiento, comprobaciones y ataques.
var _fps = game_get_speed(gamespeed_fps);
invi = max(0, invi - 1);
special_cooldown = max(0, special_cooldown - 1);
slide_cooldown = max(0, slide_cooldown - 1);
ground = place_meeting(x, y + 1, o_solid);

// La congelacion conserva el cuadro de recibir dano y no admite entradas.
if (frozen_timer > 0 && !dead) {
    frozen_timer--;
    xSpeed = 0;
    ySpeed = min(fallMax, ySpeed + grav);
    c_fighter_move();
    if (frozen_timer == 0) c_fighter_state(ground ? "stand" : "fall");
    exit;
}

state_tick++;
anim_frame += anim_fps / _fps;
var _count = sprite_get_number(anim_sprite);
anim_done = anim_frame >= _count;
if (anim_loop) {
    anim_frame = anim_frame mod _count;
    anim_done = false;
} else {
    anim_frame = min(anim_frame, _count - 0.001);
}
image_index = floor(anim_frame);

if (dead) {
    xSpeed = 0;
    ySpeed = min(fallMax, ySpeed + grav);
    c_fighter_move();
    exit;
}

if (state == "hurt") {
    hitstun = max(0, hitstun - 1);
    xSpeed = knockback;
    knockback *= 0.94;
    ySpeed = min(fallMax, ySpeed + grav);
    c_fighter_move();
    if (hitstun == 0 && anim_done) c_fighter_state(ground ? "stand" : "fall");
    exit;
}

var _locked = state == "punch" || state == "ranged" || state == "slide" || state == "jump_start";
if (state == "land" && anim_done) c_fighter_state("stand");

if (!_locked) {
    var _input = input_enabled ?
        (read_key(key_right) || (key_right_alt >= 0 && read_key(key_right_alt))) -
        (read_key(key_left) || (key_left_alt >= 0 && read_key(key_left_alt))) : 0;
    if (_input != 0) {
        right = _input > 0;
        if (sign(xSpeed) != _input) xSpeed = 0;
        xSpeed = clamp(xSpeed + _input * xAccel, -xSpeedMax, xSpeedMax);
    } else {
        xSpeed = 0;
    }
    if (ground) {
        // Una pulsacion inicia cada ataque; mantener la tecla no lo repite.
        if (input_enabled && read_key_pressed(key_jump)) {
            xSpeed = 0;
            c_fighter_state("jump_start");
        } else if (input_enabled && read_key_pressed(key_punch)) {
            xSpeed = 0;
            c_fighter_state("punch");
        } else if (input_enabled && read_key_pressed(key_ranged) && special_cooldown == 0) {
            xSpeed = 0;
            c_fighter_state("ranged");
        } else if (input_enabled && read_key_pressed(key_slide) && slide_cooldown == 0) {
            xSpeed = 0;
            c_fighter_state("slide");
            slide_cooldown = 60;
        } else if (state != "land") {
            c_fighter_state(xSpeed == 0 ? "stand" : "run");
        }
    }
}

switch (state) {
    case "jump_start":
        xSpeed = 0;
        if (anim_done) {
            ySpeed = -jumpPower;
            ground = false;
            c_fighter_state("jump");
        }
    break;
    case "punch":
        xSpeed = 0;
        if (!action_fired && anim_frame >= 4) {
            c_fighter_attack("punch");
            action_fired = true;
        }
        if (anim_done) c_fighter_state("stand");
    break;
    case "ranged":
        xSpeed = 0;
        if (!action_fired && anim_frame >= 4) {
            c_fighter_projectile();
            action_fired = true;
        }
        if (projectile_object == o_spear && action_fired) {
            if (instance_exists(active_projectile)) {
                // El cuadro de lanzamiento muestra los brazos extendidos.
                anim_frame = 4;
                image_index = 4;
                anim_done = false;
            } else {
                c_fighter_state(ground ? "stand" : "fall");
            }
        } else if (anim_done) {
            c_fighter_state("stand");
        }
    break;
    case "slide":
        // La mascara baja solo mientras la patada esta extendida.
        var _active_slide = anim_frame >= 2 && anim_frame < 6;
        mask_index = _active_slide ? s_fighter_mask_slide : s_fighter_mask;
        xSpeed = _active_slide ? (right ? 10 : -10) : 0;
        if (!action_fired && _active_slide) {
            c_fighter_attack("slide");
            action_fired = true;
        }
        if (anim_done) {
            mask_index = s_fighter_mask;
            c_fighter_state("stand");
        }
    break;
}

if (state != "slide") mask_index = s_fighter_mask;

if (input_enabled && read_key_released(key_jump) && ySpeed < -4) ySpeed = -4;
var _was_ground = ground;
ySpeed = min(fallMax, ySpeed + grav);
c_fighter_move();
if (!_was_ground && ground && (state == "fall" || state == "jump")) {
    c_fighter_state("land");
} else if (!ground && state != "punch" && state != "ranged" && state != "slide" && state != "jump_start") {
    c_fighter_state(ySpeed < 0 ? "jump" : "fall");
}

image_xscale = right ? visual_scale : -visual_scale;
image_yscale = visual_scale;
