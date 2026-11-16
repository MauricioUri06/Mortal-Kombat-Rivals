/// IA del jefe: el personaje que el jugador no eligio.
/// Como el jefe de la referencia: un estado con nombre (ai_state) y alarm[0] que decide el siguiente.
/// No mueve al luchador directamente: pulsa los mismos botones que el jugador (ai_*),
/// asi comparte con el todas las reglas, tiempos de recarga y estadisticas de o_fighter.

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
}

/// Cada Step: suelta los botones y pulsa los que pide el estado actual.
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

    var _dx = target.x - x;
    var _free = state == "stand" || state == "run" || state == "crouch";

    // Mira al rival, como los enemigos de la referencia.
    if (_free && _dx != 0) right = _dx > 0;

    // Esquivar: si un proyectil del rival viene hacia el jefe, a veces salta.
    var _shot = target.active_projectile;
    if (_free && instance_exists(_shot) && _shot != ai_dodged) {
        if (sign(x - _shot.x) == _shot.facing && abs(x - _shot.x) < 220 && abs(_shot.y - (y - 53)) < 40) {
            ai_dodged = _shot; // una sola tirada por proyectil
            var _dodge = irandom(99);
            if (_dodge < 35) {
                ai_state = "jump";
                ai_jump_dir = 0;
            } else if (_dodge < 75) {
                // Agachado hasta que pase el proyectil.
                ai_state = "crouch";
                alarm[0] = 40;
            }
        }
    }

    switch (ai_state) {
        case "approach":
            ai_move = sign(_dx);
            // Acercarse y, al llegar, punetazo o patada.
            if (abs(_dx) < punch_range && abs(target.y - y) < 40) ai_state = irandom(2) == 0 ? "kick" : "punch";
        break;

        case "retreat":
            ai_move = -sign(_dx);
            // Acorralado contra un borde: salta por encima del rival.
            if (x < 80 || x > room_width - 80) {
                ai_state = "jump";
                ai_jump_dir = sign(_dx);
            }
        break;

        case "jump":
            if (_free) {
                ai_jump = true;
            } else if (state == "jump" || state == "fall") {
                ai_move = ai_jump_dir; // control en el aire hacia delante, atras o vertical
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
            ai_crouch = true; // agachado hasta la siguiente decision
        break;

        case "ranged":
            if (_free) ai_ranged = true; else if (state == "ranged") ai_state = "wait";
        break;

        case "slide":
            if (_free) ai_slide = true; else if (state == "slide") ai_state = "wait";
        break;
    }
}

/// alarm[0]: elige la siguiente accion segun la distancia, con un factor de azar.
function c_boss_decide() {
    alarm[0] = irandom_range(18, 42); // tiempo de reaccion variable

    if (dead || !instance_exists(target)) exit;
    if (target.dead) {
        ai_state = "wait";
        exit;
    }
    // Ocupado (golpe, salto, dano...): vuelve a pensar en cuanto quede libre.
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
        // Rival en el aire: golpe antiaereo, esperar a que caiga o apartarse.
        if (_dist < punch_range + 20 && _r < 50) ai_state = "punch";
        else if (_r < 75) ai_state = "wait";
        else ai_state = "retreat";
    } else if (target.invi > 0) {
        // Rival invulnerable: no gasta ataques, se recoloca o se agacha.
        if (_dist < 150 && _r < 45) ai_state = "retreat";
        else if (_r < 60) ai_state = "crouch";
        else if (_r < 80) ai_state = "wait";
        else ai_state = "approach";
    } else if (_dist < punch_range) {
        // Cerca: sobre todo punetazo o patada.
        if (_r < 30) ai_state = "punch";
        else if (_r < 50) ai_state = "kick";
        else if (_r < 60 && _can_slide) ai_state = "slide";
        else if (_r < 68) ai_state = "crouch";
        else if (_r < 78) {
            ai_state = "jump";
            ai_jump_dir = -sign(_dx); // salto hacia atras
        }
        else if (_r < 88) ai_state = "retreat";
        else ai_state = "wait";
    } else if (_dist < kick_range) {
        // Fuera del punetazo pero al alcance de la patada.
        if (_r < 45) ai_state = "kick";
        else if (_r < 70) ai_state = "approach";
        else if (_r < 85 && _can_slide) ai_state = "slide";
        else ai_state = "wait";
    } else if (_dist < slide_range) {
        // Media distancia: deslizamiento o acercarse.
        if (_r < 30 && _can_slide) ai_state = "slide";
        else if (_r < 60) ai_state = "approach";
        else if (_r < 72 && _can_ranged) ai_state = "ranged";
        else if (_r < 85) ai_state = "jump";
        else ai_state = "wait";
    } else {
        // Lejos: ataque a distancia o acercarse.
        if (_r < 45 && _can_ranged) ai_state = "ranged";
        else if (_r < 80) ai_state = "approach";
        else if (_r < 90) ai_state = "jump";
        else ai_state = "wait";
    }
}
