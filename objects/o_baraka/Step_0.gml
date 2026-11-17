// Al morir se queda quieto y se desvanece
if (hp <= 0) {
    if (!muriendo) {
        muriendo = true;
        c_sfx(snd_enemy_die);
        hspeed = 0;
    }
    fade -= 1 / (0.6 * game_get_speed(gamespeed_fps));
    if (fade <= 0) instance_destroy();
    exit;
}

// Colocado en la room: busca al jugador solo
if (!instance_exists(target) && instance_exists(o_control)) target = o_control.player;
hit_flash = max(0, hit_flash - 1);
anim += 1 / 6; // anima a diez cuadros por segundo

// Salta al terminar la preparacion

if (state == "prep" && anim >= 2) {
    state = "air";
    anim = 0;
    c_sfx(snd_baraka_jump, 0.8);
    ground = 0;
    ySpeed -= jumpPower;
    xSpeed = xSpeedMax * sign(image_xscale);
}

// Movimiento horizontal y vertical con colisiones

if (xSpeed != 0) {
    if (xSpeed > 0) {
        move_contact_solid(0, xSpeed);
    } else {
        move_contact_solid(180, abs(xSpeed));
    }
}

if (ySpeed != 0) {
    if (ySpeed > 0) {
        if (collision_rectangle(x - 12, y - 10, x + 12, y, o_terrain, 0, 1)) {
            move_contact_solid(270, ySpeed);
        } else {
            var _ySpeed_temp = round(ySpeed);
            while (collision_rectangle(x - 12, y, x + 12, y + _ySpeed_temp, o_terrain, 0, 1) != noone and _ySpeed_temp != 0) {
                _ySpeed_temp -= 1;
            }
            y += _ySpeed_temp;
        }
    } else {
        move_contact_solid(90, abs(ySpeed));
    }
}

x = clamp(x, 24, room_width - 24);

// Comprueba si esta en el suelo

if (collision_rectangle(x - 12, y, x + 12, y + 1, o_terrain, 0, 1) and collision_rectangle(x - 12, y - 10, x + 12, y, o_terrain, 0, 1) == noone) {
    // En el suelo se detiene y aterriza
    ground = 1;
    ySpeed = 0;
    xSpeed = 0;
    if (state == "air") {
        state = "land";
        anim = 0;
    }
} else {
    // En el aire aplica la gravedad
    ground = 0;
    ySpeed += grav;
    if (ySpeed > fallMax) ySpeed = fallMax;

    if (ySpeed < 0) {
        if (!place_free(x, y - 1)) {
            ySpeed = 0;
        }
    }
}

if (state == "land" && anim >= 2) {
    state = "idle";
    anim = 0;
}

// Solo dana al jugador durante el salto

if (state == "air" && instance_exists(target)) {
    if (place_meeting(x, y, target)) c_fighter_hit(target, dmg, id, "baraka", sign(target.x - x));
}
