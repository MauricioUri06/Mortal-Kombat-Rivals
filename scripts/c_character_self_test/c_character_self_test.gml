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
        // Las pruebas de teclas usan al jugador solo.
        with (boss) instance_destroy();
    } else if (player_test_frame == 18) {
        with (o_fighter) instance_destroy();
        selecting = true;
        c_player_select_input(true, false, false);
        c_test_assert(selected_character == 0 && selecting, "Selector navigates to Sub-Zero");
        c_player_select_input(false, false, true);
        c_test_assert(player.object_index == o_player_sz && player.projectile_object == o_iceball &&
                      instance_number(o_fighter) == 2 && boss.object_index == o_boss_sc,
                      "Sub-Zero player faces a Scorpion boss");
        with (boss) instance_destroy();
    } else if (player_test_frame == 35) {
        player.hp = 1;
        with (player) c_fighter_projectile();
        c_player_start(selected_character);
        c_test_assert(player.hp == player.hpMax && player.object_index == o_player_sz &&
                      instance_number(o_fighter) == 2 && boss.object_index == o_boss_sc &&
                      boss.hp == boss.hpMax, "Restart keeps the chosen player, respawns the boss and restores health");
        c_test_assert(instance_number(o_att) == 0, "Restart clears all previous attacks");
        boss_test_frame = 0;
        boss_test_done = false;
        boss_seen = [false, false, false, false, false];
        boss_hit_player = false;
        exit;
    }

    if (player_test_frame == 1 || player_test_frame == 18) {
        c_test_assert(player.key_jump == ord("W") && player.key_jump_alt == vk_space && player.button_punch == mb_left &&
                      player.button_ranged == mb_right && player.key_slide == vk_shift,
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

    var _keys = [ord("D"), ord("A"), vk_right, vk_left, ord("W"), mb_left, mb_right, vk_shift];
    var _states = ["run", "run", "run", "run", "jump_start", "punch", "ranged", "slide"];
    var _directions = [1, -1, 1, -1];
    var _tick = player_test_frame - (player_test_frame < 18 ? 2 : 19);
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
    var _moves = ["run", "jump_start", "punch", "ranged", "slide"];
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
        c_test_assert(_all, "Boss uses run, jump, punch, ranged and slide (missing:" + _missing + ")");
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
    if (player_test_frame < 35) { c_player_self_test(); exit; }
    if (!boss_test_done) { c_boss_self_test(); exit; }
    self_test_frame++;
    var _a = instance_find(o_subzero, 0);
    var _b = instance_find(o_scorpion, 0);
    if (self_test_frame >= 362 && self_test_frame <= 430) {
        for (var _shot_index = 0; _shot_index < instance_number(o_spear); _shot_index++) {
            var _shot = instance_find(o_spear, _shot_index);
            chain_within_range = chain_within_range && _shot.travel_distance <= _shot.max_range &&
                point_distance(_shot.owner.x + _shot.facing * 30, _shot.owner.y - 53, _shot.x, _shot.y) <= _shot.max_range;
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
            show_debug_message("CHARACTER_SELF_TEST_OK: " + string(global.test_passes) + " checks");
            game_end();
        break;
    }
}
