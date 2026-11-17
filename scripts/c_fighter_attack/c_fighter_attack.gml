/// Crea un golpe delante del luchador; cada golpe puede impactar una sola vez.
function c_fighter_attack(_kind) {
    var _dir = right ? 1 : -1;
    var _hit = instance_create_layer(x, y, "att", o_hitbox);
    _hit.owner = id;
    _hit.team = player_number;
    _hit.facing = _dir;
    _hit.kind = _kind;
    switch (_kind) {
        case "slide":
            _hit.dmg = 16; _hit.life = 12;
            _hit.offset_x = 42; _hit.offset_y = -19; _hit.half_width = 36; _hit.half_height = 23; // +45 % sobre el original
        break;
        case "kick":
            // Mas dano y alcance que el punetazo, pero mas lenta; patada alta: pasa por encima del agachado.
            _hit.dmg = 14; _hit.life = 6;
            _hit.offset_x = 50; _hit.offset_y = -64; _hit.half_width = 29; _hit.half_height = 14; // +45 % sobre el original
        break;
        default:
            _hit.dmg = 10; _hit.life = 5;
            _hit.offset_x = 40; _hit.offset_y = -53; _hit.half_width = 30; _hit.half_height = 22; // +45 % sobre el original
        break;
    }
}

function c_fighter_projectile() {
    var _dir = right ? 1 : -1;
    var _shot = instance_create_layer(x + 46 * _dir, y, "att", projectile_object);
    _shot.y = y - _shot.height;
    _shot.owner = id;
    _shot.team = player_number;
    _shot.facing = _dir;
    _shot.image_xscale = _shot.scale * _dir;
    _shot.image_yscale = _shot.scale;
    active_projectile = _shot;
    special_cooldown = 72;
}
