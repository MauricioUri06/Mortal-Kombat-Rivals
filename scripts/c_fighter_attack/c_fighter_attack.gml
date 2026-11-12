/// Crea un golpe delante del luchador; cada golpe puede impactar una sola vez.
function c_fighter_attack(_kind) {
    var _dir = right ? 1 : -1;
    var _hit = instance_create_layer(x, y, "att", o_hitbox);
    _hit.owner = id;
    _hit.team = player_number;
    _hit.facing = _dir;
    _hit.kind = _kind;
    _hit.dmg = (_kind == "slide") ? 16 : 10;
    _hit.life = (_kind == "slide") ? 12 : 5;
    _hit.offset_x = (_kind == "slide") ? 38 : 36;
    _hit.offset_y = (_kind == "slide") ? -17 : -53;
    _hit.half_width = (_kind == "slide") ? 25 : 21;
    _hit.half_height = (_kind == "slide") ? 16 : 15;
}

function c_fighter_projectile() {
    var _dir = right ? 1 : -1;
    var _shot = instance_create_layer(x + 46 * _dir, y - 53, "att", projectile_object);
    _shot.owner = id;
    _shot.team = player_number;
    _shot.facing = _dir;
    _shot.image_xscale = visual_scale * _dir;
    _shot.image_yscale = visual_scale;
    active_projectile = _shot;
    special_cooldown = 72;
}
