/// Crea un golpe que impacta una vez por objetivo
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
            _hit.offset_x = 42; _hit.offset_y = -19; _hit.half_width = 36; _hit.half_height = 23; // zona de golpe del deslizamiento, mas grande
        break;
        case "kick":
            // Patada: mas dano y alcance, pero mas lenta
            _hit.dmg = 14; _hit.life = 6;
            _hit.offset_x = 50; _hit.offset_y = -64; _hit.half_width = 29; _hit.half_height = 14; // zona de golpe alta de la patada, mas grande
        break;
        default:
            _hit.dmg = 10; _hit.life = 5;
            _hit.offset_x = 40; _hit.offset_y = -53; _hit.half_width = 30; _hit.half_height = 22; // zona de golpe del punetazo, mas grande
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
    // La cadena de Scorpion solo suena al acertar (en o_projectile)
    if (projectile_object != o_spear) c_sfx(snd_iceball, 0.8);
}
