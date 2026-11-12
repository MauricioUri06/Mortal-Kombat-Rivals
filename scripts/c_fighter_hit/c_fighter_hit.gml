/// Devuelve true solamente si el golpe fue aceptado.
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
            // Arrastra hacia Scorpion, sin teletransportar al rival.
            knockback = sign(_owner.x - x) * min(8, abs(_owner.x - x) / 24);
            hitstun = 30;
            invi = 30;
        }
        xSpeed = knockback;
        if (hp <= 0) {
            dead = true;
            frozen_timer = 0;
            hitstun = 0;
            xSpeed = 0;
            c_fighter_state("death");
        } else {
            c_fighter_state("hurt");
        }
    }
    return true;
}
