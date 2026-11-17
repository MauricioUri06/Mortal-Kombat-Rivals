/// Devuelve true solo si el golpe fue aceptado
function c_fighter_hit(_target, _damage, _owner, _kind, _direction) {
    if (!instance_exists(_target)) return false;
    if (_target.dead || _target.invi > 0) return false;
    with (_target) {
        hp = max(0, hp - _damage);
        invi = invi_time;
        frozen_timer = 0;
        mask_index = s_fighter_mask;
        hitstun = 24;
        knockback = _direction * 4;
        if (_kind == "ice") {
            frozen_timer = 60;
            hitstun = 0;
            knockback = 0;
            invi = 60;
        }
        if (_kind == "spear" && instance_exists(_owner)) {
            // Arrastra al rival hacia Scorpion sin teletransportarlo
            knockback = sign(_owner.x - x) * min(8, abs(_owner.x - x) / 24);
            hitstun = 30;
            invi = 30;
        }
        xSpeed = knockback;
        // Sonido del impacto segun el tipo de golpe
        if (_kind == "ice") c_sfx(snd_freeze, 0.9); else c_sfx(snd_hit, 0.9);
        if (_kind == "trampa") c_sfx(snd_trap, 0.8);
        if (hp <= 0) c_sfx(snd_death, 1, 0.02);
        if (hp <= 0) {
            dead = true;
            frozen_timer = 0;
            hitstun = 0;
            xSpeed = 0;
            // En el duelo agacha la cabeza y espera el fatality
            var _me = id;
            var _rival = false;
            with (o_fighter) if (id != _me && !dead) _rival = true;
            c_fighter_state(_rival && _kind != "fall" ? "defeat" : "death");
        } else {
            c_fighter_state("hurt");
        }
    }
    return true;
}
