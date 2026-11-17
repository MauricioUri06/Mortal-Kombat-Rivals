/// Habilidades de nivel (tecla E):
///  - Scorpion: lanza la cadena a un o_gancho cercano y se jala hacia el.
///  - Sub-Zero: congela un o_puente_hielo cercano para poder cruzarlo.

#macro HOOK_RANGE 260      // distancia maxima (px) de la mano a la argolla
#macro HOOK_SPEED 12       // velocidad del jalon
#macro HOOK_HAND_Y 61      // altura de la mano sobre los pies
#macro BRIDGE_RANGE 110    // distancia horizontal maxima al borde del puente
#macro BRIDGE_RANGE_Y 96   // diferencia de altura maxima con la superficie del puente

/// Centro de la argolla de un o_gancho (funciona con cualquier origen del sprite).
function c_gancho_centro_x(_g) { return (_g.bbox_left + _g.bbox_right) / 2; }
function c_gancho_centro_y(_g) { return (_g.bbox_top + _g.bbox_bottom) / 2; }

/// Llamar desde un luchador: devuelve el gancho mas cercano a su alcance y sin pared en medio.
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

/// Llamar desde un luchador: devuelve el puente sin activar mas cercano a su alcance.
function c_puente_buscar() {
    var _best = noone;
    var _best_d = BRIDGE_RANGE;
    var _fx = x;
    var _fy = y;
    with (o_puente_hielo) {
        if (activo) continue;
        var _dx = max(0, bbox_left - _fx, _fx - bbox_right); // 0 si esta encima del puente
        var _dy = abs(_fy - bbox_top);
        if (_dy < BRIDGE_RANGE_Y && _dx < _best_d) {
            _best = id;
            _best_d = _dx;
        }
    }
    return _best;
}

/// Llamar desde un o_puente_hielo: lo vuelve solido y empieza la animacion.
function c_puente_activar() {
    activo = true;
    desapareciendo = false;
    // Se forma desde el lado donde esta Sub-Zero (other = el luchador que lo activo).
    desde_derecha = other.x > (bbox_left + bbox_right) / 2;
    anim = 0;
    timer = 0;
    // No crea un bloque solido: el puente solo sostiene a quien cae con los pies sobre el
    // (ver c_puente_bajo_pies). Se atraviesa por los lados y desde abajo.
}

/// Llamar desde un luchador al pulsar E. Devuelve true si hizo algo.
function c_fighter_habilidad() {
    if (projectile_object == o_spear) {
        var _g = c_gancho_buscar();
        if (_g == noone) return false;
        hook_target = _g;
        hook_timer = 0;
        right = c_gancho_centro_x(_g) >= x;
        c_fighter_state("hook");
        return true;
    }
    if (projectile_object == o_iceball) {
        var _p = c_puente_buscar();
        if (_p == noone) return false;
        with (_p) c_puente_activar();
        return true;
    }
    return false;
}

/// Llamar desde un luchador. true si, al bajar _dy pixeles, sus pies se apoyan en
/// una plataforma de un solo sentido: un puente de hielo activo o una o_nube.
/// Solo sostiene si los pies estan encima de su superficie; desde abajo o de lado
/// se atraviesa.
function c_puente_bajo_pies(_dy) {
    var _hit = false;
    var _me = id;
    var _x = x;
    var _y = y;
    var _feet = bbox_bottom;
    with (o_puente_hielo) {
        if (!activo || desapareciendo) continue;
        if (_feet > bbox_top + 2) continue; // los pies no estan encima
        var _b = id;
        with (_me) if (place_meeting(_x, _y + _dy, _b)) _hit = true;
    }
    with (o_nube) {
        if (_feet > bbox_top + 2) continue;
        var _b = id;
        with (_me) if (place_meeting(_x, _y + _dy, _b)) _hit = true;
    }
    return _hit;
}
