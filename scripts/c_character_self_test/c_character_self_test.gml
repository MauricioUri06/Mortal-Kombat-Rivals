/// Pruebas de integracion ejecutadas por Runner con --self-test.
/// No modifican el comportamiento de una partida normal.
function c_test_assert(_condition, _label) {
    if (_condition) {
        global.test_passes++;
        show_debug_message("PASS: " + _label);
    } else {
        global.test_failed = true;
        show_debug_message("FAIL: " + _label);
        game_end();
    }
}

function c_test_reset_fighters() {
    with (o_att) instance_destroy();
    with (o_fighter) {
        hp = hpMax;
        dead = false;
        invi = 0;
        frozen_timer = 0;
        hitstun = 0;
        knockback = 0;
        special_cooldown = 0;
        slide_cooldown = 0;
        xSpeed = 0;
        ySpeed = 0;
        x = player_number == 1 ? 600 : 666;
        y = 592;
        right = player_number == 1;
        image_xscale = right ? visual_scale : -visual_scale;
        mask_index = s_fighter_mask;
        ground = true;
        c_fighter_state("stand");
    }
}

// Inyecta entradas durante un frame del Runner sin enviar teclas a Windows.
function c_player_self_test() {
    player_test_frame++;
    // Deja que el selector dibuje un frame antes de empezar las pruebas.
    if (player_test_frame == 0) exit;
    if (player_test_frame == 1) {
        c_test_assert(selecting && instance_number(o_fighter) == 0, "Selector opens before spawning fighters");
        c_player_select_input(false, true, false);
        c_test_assert(selected_character == 1 && selecting, "Selector navigates to Scorpion");
        c_player_select_input(false, false, true);
        c_test_assert(!selecting && player.object_index == o_player_sc && instance_number(o_fighter) == 2,
                      "Confirm spawns the chosen Scorpion player and one boss");
        c_test_assert(player.projectile_object == o_spear && boss.object_index == o_boss_sz &&
                      boss.projectile_object == o_iceball, "Unpicked Sub-Zero becomes the boss");
        c_test_assert(boss.player_number == 2 && !boss.input_enabled && boss.target == player &&
                      boss.hpMax == player.hpMax && boss.xSpeedMax == player.xSpeedMax &&
                      boss.jumpPower == player.jumpPower, "Boss is an AI rival with the player's stats");
        c_test_assert(instance_number(o_baraka) == 1 && baraka.target == player && baraka.hp == 30,
                      "Baraka spawns with the match and targets the player");
        c_test_assert(instance_number(o_goro) == 1 && goro.target == player && goro.hp == 60 && goro.state == "walk",
                      "Goro spawns with the match, patrolling");
        // Las pruebas de teclas usan al jugador solo.
        with (boss) instance_destroy();
        with (o_enemy) instance_destroy();
    } else if (player_test_frame == 22) {
        with (o_fighter) instance_destroy();
        selecting = true;
        c_player_select_input(true, false, false);
        c_test_assert(selected_character == 0 && selecting, "Selector navigates to Sub-Zero");
        c_player_select_input(false, false, true);
        c_test_assert(player.object_index == o_player_sz && player.projectile_object == o_iceball &&
                      instance_number(o_fighter) == 2 && boss.object_index == o_boss_sc,
                      "Sub-Zero player faces a Scorpion boss");
        with (boss) instance_destroy();
        with (o_enemy) instance_destroy();
    } else if (player_test_frame == 43) {
        player.hp = 1;
        with (player) c_fighter_projectile();
        c_player_start(selected_character);
        c_test_assert(player.hp == player.hpMax && player.object_index == o_player_sz &&
                      instance_number(o_fighter) == 2 && boss.object_index == o_boss_sc &&
                      boss.hp == boss.hpMax, "Restart keeps the chosen player, respawns the boss and restores health");
        c_test_assert(instance_number(o_att) == 0, "Restart clears all previous attacks");
        // Baraka tiene sus propias pruebas al final; aqui estorbaria al jefe.
        with (o_enemy) instance_destroy();
        boss_test_frame = 0;
        boss_test_done = false;
        boss_seen = [false, false, false, false, false, false, false];
        boss_hit_player = false;
        exit;
    }

    if (player_test_frame == 1 || player_test_frame == 22) {
        c_test_assert(player.key_jump == ord("W") && player.key_jump_alt == vk_space && player.button_punch == mb_left &&
                      player.button_kick == mb_right && player.key_ranged == ord("Q") &&
                      player.key_slide == vk_shift && player.key_crouch == ord("S"),
                      player.character_name + " shared key bindings");
        with (o_fighter) {
            test_key = -1;
            read_key = method(id, function(_key) { return _key == test_key; });
            read_key_pressed = read_key;
            read_button_pressed = read_key;
            read_key_released = function(_key) { return false; };
        }
        exit;
    }

    var _keys = [ord("D"), ord("A"), vk_right, vk_left, ord("W"), mb_left, mb_right, ord("Q"), vk_shift, ord("S")];
    var _states = ["run", "run", "run", "run", "jump_start", "punch", "kick", "ranged", "slide", "crouch"];
    var _directions = [1, -1, 1, -1];
    var _tick = player_test_frame - (player_test_frame < 22 ? 2 : 23);
    var _key = _tick div 2;
    if (_tick mod 2 == 0) {
        c_test_reset_fighters();
        test_player_x = player.x;
        player.test_key = _keys[_key];
    } else {
        var _correct = player.state == _states[_key];
        if (_key < 4) _correct = _correct && sign(player.x - test_player_x) == _directions[_key];
        player.test_key = -1;
        c_test_assert(_correct, player.character_name + " key " + string(_keys[_key]) + " -> " + _states[_key]);
    }
}

// El jefe pelea contra un jugador quieto e inmortal hasta usar todos sus movimientos.
function c_boss_self_test() {
    boss_test_frame++;
    player.hp = player.hpMax;
    var _moves = ["run", "jump_start", "punch", "kick", "crouch", "ranged", "slide"];
    var _all = true;
    for (var _i = 0; _i < array_length(_moves); _i++) {
        if (boss.state == _moves[_i]) boss_seen[_i] = true;
        _all = _all && boss_seen[_i];
    }
    if (player.state == "hurt") boss_hit_player = true;
    if (_all || boss_test_frame >= 3600) {
        var _missing = "";
        for (var _j = 0; _j < array_length(_moves); _j++) {
            if (!boss_seen[_j]) _missing += " " + _moves[_j];
        }
        c_test_assert(_all, "Boss uses run, jump, punch, kick, crouch, ranged and slide (missing:" + _missing + ")");
        c_test_assert(boss_hit_player, "Boss lands hits on the player");
        show_debug_message("Boss used every move in " + string(boss_test_frame) + " frames");
        // Las pruebas de combate siguientes crean sus propios rivales.
        with (boss) instance_destroy();
        with (o_att) instance_destroy();
        boss_test_done = true;
    }
}

function c_character_self_test() {
    if (global.test_failed) exit;
    if (player_test_frame < 43) { c_player_self_test(); exit; }
    if (!boss_test_done) { c_boss_self_test(); exit; }
    self_test_frame++;
    var _a = instance_find(o_subzero, 0);
    var _b = instance_find(o_scorpion, 0);
    if (self_test_frame >= 362 && self_test_frame <= 430) {
        for (var _shot_index = 0; _shot_index < instance_number(o_spear); _shot_index++) {
            var _shot = instance_find(o_spear, _shot_index);
            chain_within_range = chain_within_range && _shot.travel_distance <= _shot.max_range &&
                point_distance(_shot.owner.x + _shot.facing * _shot.anchor_x, _shot.owner.y + _shot.anchor_y, _shot.x, _shot.y) <= _shot.max_range;
        }
    }
    switch (self_test_frame) {
        case 1:
            // Objetivo exclusivo de las pruebas de combate, nunca de una partida normal.
            _b = instance_create_layer(900, 592, "Instances", o_scorpion);
            _b.input_enabled = false;
            c_test_assert(instance_exists(_a) && instance_exists(_b), "Both character objects spawned");
            c_test_assert(_a.projectile_object == o_iceball && _b.projectile_object == o_spear, "Distinct projectiles");
            c_test_assert(_a.sprites.death != _b.sprites.death, "Independent animation sets");
            c_test_reset_fighters();
            // Movimiento fraccional y colision con una pared alta.
            with (_a) { xSpeed = 5.5; c_fighter_move(); }
            c_test_assert(abs(_a.x - 605.5) < 0.01, "Fractional horizontal motion");
            var _wall = instance_create_layer(630, 400, "terrain", o_solid);
            _wall.image_yscale = 6;
            with (_a) { xSpeed = 100; c_fighter_move(); }
            c_test_assert(_a.x < 620 && !place_meeting(_a.x, _a.y, _wall), "Fast motion stops at wall");
            with (_wall) instance_destroy();
            c_test_reset_fighters();
            with (_a) c_fighter_state("jump_start");
        break;
        case 10:
            c_test_assert(_a.y < 590 && _a.state == "jump", "Jump preparation launches upward");
        break;
        case 34:
            c_test_assert(_a.state == "fall" && _a.ySpeed > 0, "Jump changes to falling");
        break;
        case 53:
            c_test_assert(_a.ground && _a.state == "land", "Landing animation triggers on floor contact");
        break;
        case 65:
            c_test_assert(_a.state == "stand" && abs(_a.y - 592) < 1, "Landing returns to idle");
            c_test_reset_fighters();
            _b.x = 649;
            with (_a) c_fighter_state("punch");
        break;
        case 85:
            c_test_assert(_b.hp == 90 && _a.hp == 100, "Punch damages rival exactly once");
            c_test_assert(_b.state == "hurt", "Damage animation interrupts idle");
        break;
        case 115:
            c_test_assert(_b.state == "stand", "Damage animation recovers");
            c_test_reset_fighters();
            _b.x = 820;
            with (_a) c_fighter_state("ranged");
        break;
        case 151:
            c_test_assert(_b.hp == 86 && _b.frozen_timer > 0, "Ice projectile hits and freezes");
            c_test_assert(instance_number(o_iceball) == 0, "Ice projectile consumed on impact");
            c_test_assert(_a.hp == 100, "Projectile ignores its owner");
            c_test_assert(!c_fighter_hit(_b, 10, _a, "punch", 1) && _b.hp == 86,
                          "Invulnerability rejects repeated damage");
        break;
        case 215:
            c_test_assert(_b.frozen_timer == 0 && _b.state == "stand", "Freeze expires and restores control");
            c_test_reset_fighters();
            _a.x = 580;
            _b.x = 820;
            with (_b) c_fighter_state("ranged");
        break;
        case 265:
            c_test_assert(_a.hp == 80 && _a.x > 580, "Scorpion spear deals 20 damage and pulls rival");
            c_test_assert(instance_number(o_spear) == 0, "Spear consumed on impact");
            c_test_reset_fighters();
            _b.x = 680;
            with (_a) c_fighter_state("slide");
        break;
        case 282:
            c_test_assert(_a.mask_index == s_fighter_mask_slide, "Slide uses a low collision mask");
            c_test_assert(_b.hp == 84, "Sliding kick damages rival exactly once");
        break;
        case 302:
            c_test_assert(_a.state == "stand" && _a.mask_index == s_fighter_mask, "Slide restores standing mask");
            c_test_reset_fighters();
            _b.invi = 0;
            c_fighter_hit(_b, 999, _a, "punch", 1);
            c_test_assert(_b.dead && _b.hp == 0 && _b.state == "death", "Fatal hit starts death animation");
        break;
        case 360:
            c_test_assert(floor(_b.anim_frame) == 7 && _b.dead, "Death holds its last frame");
            c_test_assert(_b.hp == 0, "Health never becomes negative");
        break;
        case 361:
            c_test_reset_fighters();
            _a.x = 800;
            _b.x = 200;
            _b.right = true;
            chain_within_range = true;
            with (_b) c_fighter_projectile();
            c_test_assert(instance_find(o_spear, 0).max_range == 320, "Spear has a finite 320 pixel range");
            var _spear = instance_find(o_spear, 0);
            c_test_assert(_spear.image_yscale == 0.45 && abs(_spear.y - (_b.y - 61)) < 0.01 &&
                          _spear.y == _b.y + _spear.anchor_y, "Spear is drawn smaller and flies level with its chain");
        break;
        case 395:
            c_test_assert(instance_number(o_spear) == 0 && _a.hp == 100, "Rightward spear expires before a distant target");
            c_test_assert(chain_within_range, "Rightward chain never exceeds maximum length");
            c_test_reset_fighters();
            _a.x = 300;
            _b.x = 1080;
            chain_within_range = true;
            with (_b) c_fighter_projectile();
        break;
        case 430:
            c_test_assert(instance_number(o_spear) == 0 && _a.hp == 100, "Leftward spear expires before a distant target");
            c_test_assert(chain_within_range, "Leftward chain never exceeds maximum length");
            c_test_reset_fighters();
            _a.x = 1050;
            _b.x = 600;
            _b.right = true;
            with (_b) c_fighter_projectile();
        break;
        case 431:
            _b.x = 100;
        break;
        case 433:
            c_test_assert(instance_number(o_spear) == 0, "Chain expires when its owner moves beyond maximum reach");
        break;
        case 434:
            c_test_reset_fighters();
            _a.x = 900;
            _b.x = 200;
            _b.right = true;
            with (_b) c_fighter_state("ranged");
        break;
        case 449:
            c_test_assert(instance_exists(_b.active_projectile) && _b.state == "ranged" && floor(_b.anim_frame) == 4,
                          "Scorpion holds the extended-arm frame after launching");
        break;
        case 461:
            c_test_assert(instance_number(o_spear) == 1 && _b.state == "ranged" && floor(_b.anim_frame) == 4,
                          "Scorpion keeps holding the same pose beyond normal animation duration");
        break;
        case 480:
            c_test_assert(instance_number(o_spear) == 0 && _b.state == "stand",
                          "Scorpion returns to idle after the chain reaches its range limit");
            c_test_reset_fighters();
            _a.x = 900;
            _b.x = 200;
            _b.right = true;
            test_chain_wall = instance_create_layer(300, 400, "terrain", o_solid);
            test_chain_wall.image_yscale = 6;
            with (_b) c_fighter_state("ranged");
        break;
        case 504:
            c_test_assert(instance_number(o_spear) == 0 && _b.state == "stand",
                          "Scorpion releases the pose when the chain hits a nearby wall");
            with (test_chain_wall) instance_destroy();
            // Dos luchadores parados en el mismo sitio se separan solos.
            c_test_reset_fighters();
            _a.x = 640;
            _b.x = 640;
        break;
        case 534:
            c_test_assert(!place_meeting(_a.x, _a.y, _b) && _a.state == "stand" && _b.state == "stand",
                          "Idle fighters never stay on top of each other");
            // En movimiento si se atraviesan.
            c_test_reset_fighters();
            _a.x = 560;
            _b.x = 640;
            _a.input_enabled = false;
            _a.ai_move = 1;
        break;
        case 564:
            c_test_assert(_a.x > _b.x, "Moving fighter passes through an idle one");
            _a.ai_move = 0;
            _a.input_enabled = true;
            // Fuera del alcance del punetazo (69 px), dentro del de la patada.
            c_test_reset_fighters();
            _b.x = 672;
            with (_a) c_fighter_state("kick");
        break;
        case 589:
            // Un punetazo ya habria terminado (8 cuadros a 20 fps = 24 frames).
            c_test_assert(_a.state == "kick", "Kick is slower than a punch");
        break;
        case 594:
            c_test_assert(_b.hp == 86 && _a.hp == 100, "Kick deals 14 damage once, beyond punch range");
            c_test_reset_fighters();
            _a.input_enabled = false;
            _a.ai_crouch = true;
        break;
        case 596:
            // La lanza de Scorpion pasa por encima del agachado.
            with (_b) c_fighter_projectile();
        break;
        case 604:
            c_test_assert(_a.state == "crouch" && _a.mask_index == s_fighter_mask_crouch &&
                          _a.bbox_top > _b.bbox_top + 15 && _a.bbox_bottom == _b.bbox_bottom,
                          "Crouch lowers the collision mask");
            c_test_assert(_a.hp == 100 && instance_number(o_spear) == 1 && instance_find(o_spear, 0).x < _a.x,
                          "Crouching dodges the ranged attack");
            with (o_spear) instance_destroy();
            _a.ai_crouch = false;
        break;
        case 606:
            c_test_assert(_a.state == "stand" && _a.mask_index == s_fighter_mask, "Releasing crouch stands up");
            _a.input_enabled = true;
            // Baraka: cae, se prepara, salta hacia el jugador y aterriza (como o_jumper).
            c_test_reset_fighters();
            _b.x = 1150;
            test_baraka = instance_create_layer(1000, 560, "Instances", o_baraka);
            test_baraka.target = _a;
            test_baraka.alarm[0] = 30;
        break;
        case 630:
            c_test_assert(test_baraka.ground && test_baraka.state == "idle" && test_baraka.y > 580,
                          "Baraka falls onto the ground");
        break;
        case 640:
            c_test_assert(test_baraka.state == "prep" && test_baraka.ground && test_baraka.image_xscale < 0,
                          "Baraka crouches facing the player before leaping");
        break;
        case 655:
            c_test_assert(test_baraka.state == "air" && test_baraka.y < 580 && test_baraka.xSpeed < 0,
                          "Baraka leaps toward the player");
        break;
        case 715:
            c_test_assert(test_baraka.ground && test_baraka.xSpeed == 0 && test_baraka.x < 1000 &&
                          test_baraka.x > _a.x + 24, "Baraka lands closer and stops");
            test_baraka.alarm[0] = 999;
            test_baraka.x = _a.x;
            _a.invi = 0;
        break;
        case 717:
            c_test_assert(_a.hp == 100 && _a.state != "hurt", "Touching Baraka while it stands still does no damage");
            // Ahora salta desde cerca y alcanza al jugador en el aire.
            test_baraka.x = _a.x + 60;
            test_baraka.alarm[0] = 1;
        break;
        case 745:
            c_test_assert(_a.hp == 85 && _a.state == "hurt", "Baraka's leap deals 15 damage on contact");
            c_test_reset_fighters();
            _b.x = 1150;
            with (test_baraka) {
                state = "idle";
                x = 650;
                y = 591;
                xSpeed = 0;
                ySpeed = 0;
                alarm[0] = 999;
            }
            with (_a) c_fighter_state("punch");
        break;
        case 765:
            c_test_assert(test_baraka.hp == 20, "The player's punch damages Baraka");
            test_baraka.hp = 5;
            with (_a) c_fighter_projectile();
        break;
        case 769:
            c_test_assert(!instance_exists(test_baraka), "Baraka dies when its health runs out");
            // Goro sin objetivo: patrulla y da la vuelta al final del mapa.
            c_test_reset_fighters();
            _b.x = 1150;
            test_goro = instance_create_layer(60, 591, "Instances", o_goro);
            test_goro.hspeed = -test_goro.walkSpeed;
            test_goro.image_xscale = -test_goro.visual_scale;
            test_wall = instance_create_layer(150, 400, "terrain", o_solid);
            test_wall.image_yscale = 6;
        break;
        case 790:
            c_test_assert(test_goro.hspeed > 0 && test_goro.image_xscale > 0, "Goro turns around at the end of the map");
        break;
        case 860:
            c_test_assert(test_goro.hspeed < 0 && test_goro.x < 150, "Goro turns around at a wall");
            with (test_wall) instance_destroy();
            // Sobre una plataforma: al llegar al borde no cae, da la vuelta.
            test_wall = instance_create_layer(700, 500, "terrain", o_solid);
            test_wall.image_xscale = 4;
            test_wall.image_yscale = 0.5;
            test_goro.x = 800;
            test_goro.y = 499;
            test_goro.hspeed = test_goro.walkSpeed;
            test_goro.image_xscale = test_goro.visual_scale;
        break;
        case 880:
            c_test_assert(test_goro.hspeed < 0 && test_goro.x < 828 && test_goro.y == 499,
                          "Goro turns around at a ledge instead of falling");
            with (test_wall) instance_destroy();
            // Ve al jugador en su misma linea y lo embiste.
            c_test_reset_fighters();
            _b.x = 1150;
            test_goro.x = 1000;
            test_goro.y = 591;
            test_goro.hspeed = -test_goro.walkSpeed;
            test_goro.image_xscale = -test_goro.visual_scale;
            test_goro.target = _a;
        break;
        case 930:
            c_test_assert(_a.hp == 80 && _a.state == "hurt" && test_goro.state == "dazed" && test_goro.hspeed == 0,
                          "Goro tackles the player on sight and ends up dazed");
        break;
        case 990:
            c_test_assert(test_goro.state == "dazed", "Goro stays dazed after the hit");
            test_goro.target = noone;
        break;
        case 1050:
            c_test_assert(test_goro.state == "walk" && test_goro.hspeed != 0, "Goro recovers after two seconds");
            // La embestida tambien termina contra una pared, sin llegar al jugador.
            c_test_reset_fighters();
            _b.x = 1150;
            test_goro.x = 1000;
            test_goro.target = _a;
            test_goro.image_xscale = -test_goro.visual_scale;
            test_goro.state = "tackle";
            test_goro.hspeed = -test_goro.tackleSpeed;
            test_wall = instance_create_layer(800, 400, "terrain", o_solid);
            test_wall.image_yscale = 6;
        break;
        case 1080:
            c_test_assert(test_goro.state == "dazed" && test_goro.x > 832 && _a.hp == 100,
                          "Goro's tackle stops at a wall and leaves him dazed");
            with (test_wall) instance_destroy();
            c_test_reset_fighters();
            _b.x = 1150;
            test_goro.x = 650;
            test_goro.target = noone;
            test_goro.alarm[0] = 999;
            with (_a) c_fighter_state("punch");
        break;
        case 1100:
            c_test_assert(test_goro.hp == 50, "The player's punch damages Goro");
            test_goro.hp = 5;
            with (_a) c_fighter_projectile();
        break;
        case 1104:
            c_test_assert(!instance_exists(test_goro), "Goro dies when its health runs out");
            show_debug_message("CHARACTER_SELF_TEST_OK: " + string(global.test_passes) + " checks");
            game_end();
        break;
    }
}
