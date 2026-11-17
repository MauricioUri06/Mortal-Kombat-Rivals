// Entradas, movimiento, comprobaciones y ataques del luchador
var _fps = game_get_speed(gamespeed_fps);
invi = max(0, invi - 1);
special_cooldown = max(0, special_cooldown - 1);
slide_cooldown = max(0, slide_cooldown - 1);
ground = place_meeting(x, y + 1, o_solid) || (ySpeed >= 0 && c_puente_bajo_pies(1));
if (ground) air_jumps = air_jumps_max;
dash_cd = max(0, dash_cd - 1);
if (ground) dash_air_used = false;
if (state == "wall" || state == "hook" || state == "dash") fall_timer = 0; // agarrado, con gancho o dash no cuenta caida

// Congelado conserva el cuadro de dano, sin control
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

// Dash: impulso horizontal sin gravedad con espejismos
if (state == "dash") {
    dash_timer--;
    xSpeed = dash_dir * dash_speed;
    ySpeed = 0;
    if (dash_timer mod 2 == 0) {
        var _e = instance_create_depth(x, y, depth + 1, o_espejismo);
        _e.spr = anim_sprite;
        _e.frame = floor(anim_frame);
        _e.xs = right ? visual_scale : -visual_scale;
        _e.ys = visual_scale;
        _e.col = (projectile_object == o_iceball) ? make_colour_rgb(80, 175, 255) : make_colour_rgb(255, 205, 50);
    }
    c_fighter_move();
    if (dash_timer <= 0 || xSpeed == 0) {
        // Al terminar conserva un poco de impulso
        xSpeed = dash_dir * xSpeedMax;
        wall_lock = 4;
        c_fighter_state(ground ? "stand" : "fall");
    }
    image_xscale = right ? visual_scale : -visual_scale;
    exit;
}

// Empezar un dash con E si esta desbloqueado
if (input_enabled && dash_cd == 0 && variable_global_exists("dash_desbloqueado") && global.dash_desbloqueado
&& read_key_pressed(key_dash) && (ground || !dash_air_used)
&& (state == "stand" || state == "run" || state == "crouch" || state == "jump" || state == "fall"
    || state == "land" || state == "wall" || state == "wall_jump")) {
    dash_dir = right ? 1 : -1; // en la pared ya mira hacia afuera
    if (!ground) dash_air_used = true;
    dash_timer = dash_frames;
    dash_cd = dash_cooldown;
    ySpeed = 0;
    c_fighter_state("dash");
    image_xscale = right ? visual_scale : -visual_scale;
    exit;
}

// Gancho: se jala en linea recta, sin gravedad
if (state == "hook") {
    hook_timer++;
    if (!instance_exists(hook_target)) { c_fighter_state("fall"); exit; }
    var _gx = c_gancho_centro_x(hook_target);
    var _gy = c_gancho_centro_y(hook_target) + HOOK_HAND_Y; // la mano del jugador llega a la argolla
    var _hdist = point_distance(x, y, _gx, _gy);
    var _hdir = point_direction(x, y, _gx, _gy);
    var _hspd = min(HOOK_SPEED, _hdist);
    xSpeed = lengthdir_x(_hspd, _hdir);
    ySpeed = lengthdir_y(_hspd, _hdir);
    // Cuadros: lanzar, volar en bucle y llegar
    if (variable_struct_exists(sprites, "hook")) {
        var _hf;
        if (_hdist < HOOK_SPEED * 1.5) _hf = 7;
        else if (_hdist < HOOK_SPEED * 3) _hf = 6;
        else if (hook_timer < 4) _hf = 0;
        else if (hook_timer < 8) _hf = 1;
        else _hf = 2 + ((hook_timer div 4) mod 4);
        anim_frame = min(_hf, sprite_get_number(anim_sprite) - 1);
        image_index = floor(anim_frame);
    }
    var _px = x;
    var _py = y;
    c_fighter_move();
    var _stuck = hook_timer > 2 && point_distance(_px, _py, x, y) < 0.5;
    if (_hdist <= HOOK_SPEED || _stuck || hook_timer > 90) {
        // Al llegar salta un poco para subir
        hook_target = noone;
        air_jumps = air_jumps_max;
        ySpeed = -jumpPower * 0.75;
        xSpeed = (right ? 1 : -1) * 3;
        wall_lock = 10;
        ground = false;
        c_fighter_state("jump");
    }
    image_xscale = right ? visual_scale : -visual_scale;
    exit;
}

// Agarrado a la pared: se desliza lento
// Se suelta al saltar, agacharse o pasar el tiempo
if (state == "wall") {
    var _fps_w = game_get_speed(gamespeed_fps);
    // Desde la pared tambien puede usar su habilidad
    if (input_enabled && read_key_pressed(key_ability) && c_fighter_habilidad() && state == "hook") exit;
    wall_timer++;
    right = wall_dir < 0; // mira hacia afuera de la pared
    xSpeed = 0;
    ySpeed = min(ySpeed + grav * 0.25, wall_slide_speed);
    if (variable_struct_exists(sprites, "wall")) {
        anim_frame = (wall_timer div 10) mod 2;
        image_index = anim_frame;
    }
    if (read_key_pressed(key_jump) || read_key_pressed(key_jump_alt)) {
        // Rebota saltando hacia el lado contrario
        ySpeed = -jumpPower;
        xSpeed = -wall_dir * xSpeedMax * 1.3;
        right = wall_dir < 0;
        wall_lock = 12;
        wall_last_dir = wall_dir;
        wall_regrab = 15;
        c_fighter_state("wall_jump");
        c_sfx(snd_jump, 0.7);
    } else if (read_key_pressed(key_crouch) || read_key_pressed(key_crouch_alt) || wall_timer >= wall_grab_time * _fps_w) {
        // Se suelta de la pared y cae
        wall_last_dir = wall_dir;
        wall_regrab = 30;
        c_fighter_state("fall");
    }
    c_fighter_move();
    if (state == "wall") {
        if (ground) c_fighter_state("land");
        else if (!place_meeting(x + wall_dir, y, o_solid)) c_fighter_state("fall");
    }
    image_xscale = right ? visual_scale : -visual_scale;
    exit;
}

// Habilidad con Alt: gancho o puente de hielo
if (input_enabled && read_key_pressed(key_ability)
&& (state == "stand" || state == "run" || state == "crouch" || state == "jump" || state == "fall" || state == "land" || state == "wall" || state == "wall_jump")) {
    if (c_fighter_habilidad() && state == "hook") exit;
}

var _salto_suelo = false; // salto desde el suelo este frame, no doble
wall_lock = max(0, wall_lock - 1);
wall_regrab = max(0, wall_regrab - 1);
var _locked = state == "punch" || state == "kick" || state == "ranged" || state == "slide" || state == "jump_start";
if (state == "land" && anim_done) c_fighter_state("stand");

if (!_locked) {
    var _input = input_enabled ?
        (read_key(key_right) || (key_right_alt >= 0 && read_key(key_right_alt))) -
        (read_key(key_left) || (key_left_alt >= 0 && read_key(key_left_alt))) : ai_move;
    var _crouch = input_enabled ? (read_key(key_crouch) || read_key(key_crouch_alt)) : ai_crouch;
    if (wall_lock > 0) {
        // Tras rebotar o el gancho conserva el impulso
    } else if (_input != 0) {
        right = _input > 0;
        if (sign(xSpeed) != _input) xSpeed = 0;
        xSpeed = clamp(xSpeed + _input * xAccel, -xSpeedMax, xSpeedMax);
    } else {
        xSpeed = 0;
    }
    if (ground) {
        // Cada ataque empieza al pulsar su boton
        if ((input_enabled && (read_key_pressed(key_jump) || read_key_pressed(key_jump_alt))) || ai_jump) {
            // Salto inmediato que conserva la velocidad horizontal
            ySpeed = -jumpPower;
            ground = false;
            air_jumps = air_jumps_max;
            _salto_suelo = true;
            c_fighter_state("jump");
            c_sfx(snd_jump, 0.7);
        } else if ((input_enabled && (read_button_pressed(button_punch) || read_button(button_punch))) || ai_punch) {
            // Mantener el boton repite el mismo golpe
            xSpeed = 0;
            c_fighter_state("punch");
        } else if ((input_enabled && (read_button_pressed(button_kick) || read_button(button_kick))) || ai_kick) {
            xSpeed = 0;
            c_fighter_state("kick");
        } else if (((input_enabled && (read_key_pressed(key_ranged) || read_key(key_ranged))) || ai_ranged) && special_cooldown == 0) {
            xSpeed = 0;
            c_fighter_state("ranged");
        } else if (((input_enabled && read_key_pressed(key_slide)) || ai_slide) && slide_cooldown == 0) {
            xSpeed = 0;
            c_fighter_state("slide");
            slide_cooldown = 60;
        } else if (_crouch) {
            // Agachado no se desplaza pero puede girarse
            xSpeed = 0;
            if (state != "land" || anim_done) c_fighter_state("crouch");
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
            c_sfx(snd_jump, 0.7);
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
    case "kick":
        // La patada es mas lenta que el golpe
        xSpeed = 0;
        if (!action_fired && anim_frame >= 4) {
            c_fighter_attack("kick");
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
                // Muestra los brazos extendidos mientras dura la cadena
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
        // La mascara baja solo durante la patada deslizante
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

if (state == "crouch") mask_index = s_fighter_mask_crouch;
else if (state != "slide") mask_index = s_fighter_mask;

// Se agarra a una pared moviendose hacia ella
if (input_enabled && !ground && (state == "jump" || state == "fall" || state == "wall_jump") && ySpeed > -3) {
    var _wall_r = place_meeting(x + 1, y, o_solid);
    var _wall_l = place_meeting(x - 1, y, o_solid);
    if (_wall_r || _wall_l) {
        var _wd = _wall_r ? 1 : -1;
        var _hold = (read_key(key_right) || (key_right_alt >= 0 && read_key(key_right_alt)))
                  - (read_key(key_left) || (key_left_alt >= 0 && read_key(key_left_alt)));
        var _toward = _hold == _wd || sign(xSpeed) == _wd;
        if (_toward && !(_wd == wall_last_dir && wall_regrab > 0)) {
            wall_dir = _wd;
            wall_timer = 0;
            air_jumps = air_jumps_max;
            dash_air_used = false;
            xSpeed = 0;
            ySpeed = 0;
            right = wall_dir < 0;
            c_fighter_state("wall");
            image_xscale = right ? visual_scale : -visual_scale;
            exit;
        }
    }
}

// Doble salto: pulsar salto otra vez en el aire
if (input_enabled && !ground && !_salto_suelo && (state == "jump" || state == "fall" || state == "wall_jump") && air_jumps > 0
&& (read_key_pressed(key_jump) || read_key_pressed(key_jump_alt))) {
    air_jumps--;
    ySpeed = -jumpPower * double_jump_power;
    c_sfx(snd_jump, 0.7);
    if (state == "jump") {
        // Reinicia la animacion de salto desde el principio
        anim_frame = 0;
        anim_done = false;
    } else {
        c_fighter_state("jump");
    }
}

if (input_enabled && (read_key_released(key_jump) || read_key_released(key_jump_alt)) && ySpeed < -4) ySpeed = -4;
var _was_ground = ground;
ySpeed = min(fallMax, ySpeed + grav);
c_fighter_move();
if (!_was_ground && ground && (state == "fall" || state == "jump" || state == "wall_jump")) {
    c_fighter_state("land");
} else if (!ground && state != "punch" && state != "kick" && state != "ranged" && state != "slide" && state != "jump_start"
&& !(state == "wall_jump" && !anim_done)) {
    c_fighter_state(ySpeed < 0 ? "jump" : "fall");
}

// Si cae demasiado vuelve al ultimo suelo firme
if (input_enabled && !dead) {
    if (ground && place_meeting(x, y + 1, o_solid)) {
        safe_x = x;
        safe_y = y;
    }
    if (!ground && ySpeed > 0 && (state == "fall" || state == "jump" || state == "wall_jump")) fall_timer++;
    else fall_timer = 0;
    if (fall_timer >= fall_return_time * game_get_speed(gamespeed_fps)) {
        if (room == Nivel2) {
            // En el Nivel 2 vuelve al ultimo checkpoint
            if (global.checkpoint_activo) { x = global.checkpoint_x; y = global.checkpoint_y; }
            else { x = spawn_x; y = spawn_y; }
            var _n = 0;
            while (place_meeting(x, y, o_solid) && _n < 256) { y--; _n++; }
        } else {
            x = safe_x;
            y = safe_y;
        }
        xSpeed = 0;
        ySpeed = 0;
        fall_timer = 0;
        ground = true;
        invi = 0;
        c_fighter_state("stand");
        // Cada caida quita vida y puede matar
        c_fighter_hit(id, caida_dano, noone, "caida", 0);
        c_sfx(snd_respawn, 0.8);
    }
}

// Parados nunca quedan uno encima del otro
if (xSpeed == 0) {
    var _other = instance_place(x, y, o_fighter);
    if (_other != noone) {
        var _push = x < _other.x ? -2 : 2;
        if (x == _other.x) _push = player_number == 1 ? -2 : 2;
        if (!place_meeting(x + _push, y, o_solid)) x = clamp(x + _push, 24, room_width - 24);
    }
}

image_xscale = right ? visual_scale : -visual_scale;
image_yscale = visual_scale;
