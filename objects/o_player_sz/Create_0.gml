// Sub-Zero jugable: hereda todo de o_subzero
event_inherited();
player_number = 1;
right = true;
spawn_right = true;
key_left = ord("A");
key_right = ord("D");
key_left_alt = vk_left;
key_right_alt = vk_right;
key_jump = ord("W");
button_punch = mb_left;
button_kick = mb_right;
key_ranged = ord("Q");
key_slide = ord("E");
key_crouch = ord("S");
// El jugador es mas rapido que el jefe
xSpeedMax *= 1.2;
xAccel *= 1.2;
// Ataques un veinte por ciento mas rapidos
attack_speed = 1.2;
