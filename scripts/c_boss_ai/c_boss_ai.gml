/// IA del jefe: el personaje que no elegiste
/// Un estado con nombre y una alarma que decide
/// Pulsa los mismos botones virtuales que el jugador

function c_boss_init() {
    player_number = 2;
    input_enabled = false;
    right = false;
    spawn_right = false;
    target = noone;

    ai_state = "wait";
    ai_jump_dir = 0;
    ai_dodged = noone;

    punch_range = 60;
    kick_range = 75;
    slide_range = 170;
    ranged_range_spear = 300;

    alarm[0] = 60; // pausa inicial antes de la primera decision

    // Rango de activacion: espera hasta ver al jugador
    boss_xrange = 700;
    boss_yrange = 300;
    boss_activo = false;
}

/// Cada Step suelta botones y pulsa los nuevos
function c_boss_step() {
    ai_move = 0;
    ai_jump = false;
    ai_punch = false;
    ai_ranged = false;
    ai_slide = false;
    ai_kick = false;
    ai_crouch = false;

    if (dead || !instance_exists(target)) exit;
    if (target.dead) exit;
    if (!boss_activo) {
        if (abs(target.x - x) > boss_xrange || abs(target.y - y) > boss_yrange) exit;
        boss_activo = true; // ya vio al jugador: pelea hasta el final
    }

    var _dx = target.x - x;
    var _free = state == "stand" || state == "run" || state == "crouch";

    // Mira siempre hacia el rival cuando esta libre
    if (_free && _dx != 0) right = _dx > 0;

    // Esquiva proyectiles saltando o agachandose a veces
    var _shot = target.active_projectile;
    if (_free && instance_exists(_shot) && _shot != ai_dodged) {
        if (sign(x - _shot.x) == _shot.facing && abs(x - _shot.x) < 220 && abs(_shot.y - (y - 53)) < 40) {
            ai_dodged = _shot; // decide una sola vez por cada proyectil
            var _dodge = irandom(99);
            if (_dodge < 35) {
                ai_state = "jump";
                ai_jump_dir = 0;
            } else if (_dodge < 75) {
                // Se queda agachado hasta que pase el proyectil
                ai_state = "crouch";
                alarm[0] = 40;
            }
        }
    }

    switch (ai_state) {
        case "approach":
            ai_move = sign(_dx);
            // Se acerca y al llegar golpea o patea
            if (abs(_dx) < punch_range && abs(target.y - y) < 40) ai_state = irandom(2) == 0 ? "kick" : "punch";
        break;

        case "retreat":
            ai_move = -sign(_dx);
            // Acorralado contra un borde salta sobre el rival
            if (x < 80 || x > room_width - 80) {
                ai_state = "jump";
                ai_jump_dir = sign(_dx);
            }
        break;

        case "jump":
            if (_free) {
                ai_jump = true;
            } else if (state == "jump" || state == "fall") {
                ai_move = ai_jump_dir; // control en el aire hacia donde salto
            } else if (state == "land") {
                ai_state = "wait";
            }
        break;

        case "punch":
            if (_free) ai_punch = true; else if (state == "punch") ai_state = "wait";
        break;

        case "kick":
            if (_free) ai_kick = true; else if (state == "kick") ai_state = "wait";
        break;

        case "crouch":
            ai_crouch = true; // agachado hasta que tome la siguiente decision
        break;

        case "ranged":
            if (_free) ai_ranged = true; else if (state == "ranged") ai_state = "wait";
        break;

        case "slide":
            if (_free) ai_slide = true; else if (state == "slide") ai_state = "wait";
        break;
    }
}

/// Elige la accion segun la distancia y el azar
function c_boss_decide() {
    alarm[0] = irandom_range(18, 42); // tiempo de reaccion variable entre dos decisiones

    if (dead || !instance_exists(target)) exit;
    if (target.dead) {
        ai_state = "wait";
        exit;
    }
    // Si esta ocupado vuelve a pensar muy pronto
    if (state != "stand" && state != "run" && state != "crouch") {
        alarm[0] = 6;
        exit;
    }

    var _dx = target.x - x;
    var _dist = abs(_dx);
    var _r = irandom(99);
    var _can_ranged = special_cooldown == 0;
    if (projectile_object == o_spear && _dist > ranged_range_spear) _can_ranged = false;
    var _can_slide = slide_cooldown == 0;
    ai_jump_dir = sign(_dx);

    if (!target.ground) {
        // Rival en el aire: golpe, esperar o apartarse
        if (_dist < punch_range + 20 && _r < 50) ai_state = "punch";
        else if (_r < 75) ai_state = "wait";
        else ai_state = "retreat";
    } else if (target.invi > 0) {
        // Rival invulnerable: no gasta ataques, se recoloca
        if (_dist < 150 && _r < 45) ai_state = "retreat";
        else if (_r < 60) ai_state = "crouch";
        else if (_r < 80) ai_state = "wait";
        else ai_state = "approach";
    } else if (_dist < punch_range) {
        // Cerca del rival: sobre todo golpe o patada
        if (_r < 30) ai_state = "punch";
        else if (_r < 50) ai_state = "kick";
        else if (_r < 60 && _can_slide) ai_state = "slide";
        else if (_r < 68) ai_state = "crouch";
        else if (_r < 78) {
            ai_state = "jump";
            ai_jump_dir = -sign(_dx); // salta hacia atras para alejarse del rival
        }
        else if (_r < 88) ai_state = "retreat";
        else ai_state = "wait";
    } else if (_dist < kick_range) {
        // Fuera del golpe pero al alcance de patada
        if (_r < 45) ai_state = "kick";
        else if (_r < 70) ai_state = "approach";
        else if (_r < 85 && _can_slide) ai_state = "slide";
        else ai_state = "wait";
    } else if (_dist < slide_range) {
        // Media distancia: deslizarse o acercarse al rival
        if (_r < 30 && _can_slide) ai_state = "slide";
        else if (_r < 60) ai_state = "approach";
        else if (_r < 72 && _can_ranged) ai_state = "ranged";
        else if (_r < 85) ai_state = "jump";
        else ai_state = "wait";
    } else {
        // Lejos del rival: ataque a distancia o acercarse
        if (_r < 45 && _can_ranged) ai_state = "ranged";
        else if (_r < 80) ai_state = "approach";
        else if (_r < 90) ai_state = "jump";
        else ai_state = "wait";
    }
}
