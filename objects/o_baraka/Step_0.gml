// Muerte, como o_enemy_body ---------

if (hp <= 0) {
    instance_destroy();
    exit;
}

// Colocado a mano en la room: busca al jugador cuando aparece.
if (!instance_exists(target) && instance_exists(o_control)) target = o_control.player;
hit_flash = max(0, hit_flash - 1);
anim += 1 / 6; // 10 cuadros por segundo

// Salto al terminar la preparacion (lo que hace la alarma de o_jumper) --

if (state == "prep" && anim >= 2) {
    state = "air";
    anim = 0;
    ground = 0;
    ySpeed -= jumpPower;
    xSpeed = xSpeedMax * sign(image_xscale);
}

// Movimiento, igual que o_jumper -----

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

// Checks ------------------------------

if (collision_rectangle(x - 12, y, x + 12, y + 1, o_terrain, 0, 1) and collision_rectangle(x - 12, y - 10, x + 12, y, o_terrain, 0, 1) == noone) {
    // ground --------------
    ground = 1;
    ySpeed = 0;
    xSpeed = 0;
    if (state == "air") {
        state = "land";
        anim = 0;
    }
} else {
    // air ------------------
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

// Dano por contacto (como la colision del jugador con o_enemy), solo durante el salto --

if (state == "air" && instance_exists(target)) {
    if (place_meeting(x, y, target)) c_fighter_hit(target, dmg, id, "baraka", sign(target.x - x));
}
