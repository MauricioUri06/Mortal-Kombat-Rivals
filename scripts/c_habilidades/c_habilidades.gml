/// Habilidades de nivel que se usan con Alt
/// Scorpion: se jala hacia un o_gancho cercano
/// Sub-Zero: congela un o_puente_hielo cercano

#macro HOOK_RANGE 260 // distancia maxima de la mano a la argolla
#macro HOOK_SPEED 12 // velocidad a la que se jala Scorpion
#macro HOOK_HAND_Y 61 // altura de la mano sobre los pies
#macro BRIDGE_RANGE 110 // distancia horizontal maxima al borde del puente
#macro BRIDGE_RANGE_Y 96 // diferencia de altura maxima con el puente

/// Centro de la argolla con cualquier origen de sprite
function c_gancho_centro_x(_g) { return (_g.bbox_left + _g.bbox_right) / 2; }
function c_gancho_centro_y(_g) { return (_g.bbox_top + _g.bbox_bottom) / 2; }

/// Devuelve el gancho mas cercano sin paredes entre medio
function c_gancho_buscar() {
    var _best = noone;
    var _best_d = HOOK_RANGE;
    var _hx = x;
    var _hy = y - HOOK_HAND_Y;
    with (o_gancho) {
        var _gx = c_gancho_centro_x(id);
        var _gy = c_gancho_centro_y(id);
        var _d = point_distance(_hx, _hy, _gx, _gy);
        if (_d < _best_d && collision_line(_hx, _hy, _gx, _gy, o_solid, false, true) == noone) {
            _best = id;
            _best_d = _d;
        }
    }
    return _best;
}

/// Devuelve el puente sin activar mas cercano
function c_puente_buscar() {
    var _best = noone;
    var _best_d = BRIDGE_RANGE;
    var _fx = x;
    var _fy = y;
    with (o_puente_hielo) {
        if (activo) continue;
        var _dx = max(0, bbox_left - _fx, _fx - bbox_right); // vale cero si esta encima del puente
        var _dy = abs(_fy - bbox_top);
        if (_dy < BRIDGE_RANGE_Y && _dx < _best_d) {
            _best = id;
            _best_d = _dx;
        }
    }
    return _best;
}

/// Desde o_puente_hielo: lo activa y anima
function c_puente_activar() {
    activo = true;
    desapareciendo = false;
    // Se forma desde el lado donde esta Sub-Zero
    desde_derecha = other.x > (bbox_left + bbox_right) / 2;
    anim = 0;
    timer = 0;
    c_sfx(snd_ice_bridge, 0.8);
    // No crea bloque solido, sostiene solo desde arriba
}

/// Desde un luchador al pulsar Alt, true si funciona
function c_fighter_habilidad() {
    if (projectile_object == o_spear) {
        var _g = c_gancho_buscar();
        if (_g == noone) return false;
        hook_target = _g;
        hook_timer = 0;
        right = c_gancho_centro_x(_g) >= x;
        c_fighter_state("hook");
        c_dash_resetear();
        return true;
    }
    if (projectile_object == o_iceball) {
        var _p = c_puente_buscar();
        if (_p == noone) return false;
        with (_p) c_puente_activar();
        c_dash_resetear();
        return true;
    }
    return false;
}

/// True si los pies se apoyan en una plataforma
/// Plataformas de un solo sentido: puente o nube
function c_puente_bajo_pies(_dy) {
    return c_plataforma_bajo_pies(_dy) != noone;
}

/// Tolerancia en pixeles para subirse a una plataforma
#macro PLATAFORMA_TOL 12

/// Devuelve la plataforma que sostiene al luchador o noone
function c_plataforma_bajo_pies(_dy) {
    var _hit = noone;
    var _me = id;
    var _x = x;
    var _y = y;
    var _feet = bbox_bottom;
    with (o_puente_hielo) {
        if (_hit != noone) break;
        if (!activo || desapareciendo) continue;
        if (_feet > bbox_top + PLATAFORMA_TOL) continue; // los pies estan debajo de la superficie
        var _b = id;
        with (_me) if (place_meeting(_x, _y + _dy, _b)) _hit = _b;
    }
    with (o_nube) {
        if (_hit != noone) break;
        if (_feet > bbox_top + PLATAFORMA_TOL) continue;
        var _b = id;
        with (_me) if (place_meeting(_x, _y + _dy, _b)) _hit = _b;
    }
    return _hit;
}

/// Si quedo hundido en la plataforma, lo sube
function c_plataforma_ajustar() {
    var _p = c_plataforma_bajo_pies(1);
    if (_p == noone) exit;
    var _sube = bbox_bottom - (_p.bbox_top - 1);
    if (_sube > 0 && _sube <= PLATAFORMA_TOL + 1 && !place_meeting(x, y - _sube, o_solid)) y -= _sube;
}

/// Recupera el dash sin espera y en el aire
function c_dash_resetear() {
    dash_air_used = false;
    dash_cd = 0;
}
