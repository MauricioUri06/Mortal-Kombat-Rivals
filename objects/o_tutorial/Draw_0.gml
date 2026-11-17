var _keys = [];
var _txt = "";
switch (tipo) {
    // Texto bajo todas las teclas o uno por tecla
    case "mover":       _keys = ["A", "D"];                     _txt = "Moverse"; break;
    case "saltar":      _keys = ["ESPACIO"];                    _txt = "Saltar"; break;
    case "doble_salto": _keys = ["ESPACIO", "ESPACIO"];         _txt = "Doble salto"; break;
    case "pared":       _keys = ["ESPACIO"];                    _txt = "Salta contra la pared y vuelve a saltar"; break;
    case "ataques":     _keys = ["CLIC IZQ", "CLIC DER", "Q", "SHIFT"];  _txt = ["Golpe", "Patada", "Distancia", "Deslizarse"]; break;
    case "dash":        _keys = ["E"];                          _txt = "Dash"; break;
    case "agachar":     _keys = ["S", "SHIFT"];                 _txt = ["Agacharse", "Deslizarse"]; break;
    case "habilidad":
        _keys = ["ALT"];
        _txt = "Sub-Zero: crear puente de hielo   /   Scorpion: lanzar gancho";
        if (instance_exists(o_control)) {
            var _p = o_control.player;
            if (instance_exists(_p)) _txt = (_p.projectile_object == o_iceball) ? "Crear puente de hielo" : "Lanzar el gancho";
        }
    break;
}
c_tutorial_dibujar(x, y, _keys, _txt, alpha);
