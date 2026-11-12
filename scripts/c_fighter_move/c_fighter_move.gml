/// Movimiento por pasos pequenos: no atraviesa paredes al deslizarse.
function c_fighter_move() {
    var _remaining = abs(xSpeed);
    var _sign = sign(xSpeed);
    while (_remaining > 0.0001) {
        var _amount = min(1, _remaining) * _sign;
        if (place_meeting(x + _amount, y, o_solid)) {
            xSpeed = 0;
            break;
        }
        x += _amount;
        _remaining -= abs(_amount);
    }
    x = clamp(x, 24, room_width - 24);

    _remaining = abs(ySpeed);
    _sign = sign(ySpeed);
    while (_remaining > 0.0001) {
        var _amount_y = min(1, _remaining) * _sign;
        if (place_meeting(x, y + _amount_y, o_solid)) {
            ySpeed = 0;
            break;
        }
        y += _amount_y;
        _remaining -= abs(_amount_y);
    }
    ground = place_meeting(x, y + 1, o_solid);
    if (ground && ySpeed > 0) ySpeed = 0;
    if (y > room_height + 200) c_fighter_hit(id, hpMax, noone, "fall", 0);
}
