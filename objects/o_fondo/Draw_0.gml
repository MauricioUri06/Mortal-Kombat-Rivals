var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);
var _sw = sprite_get_width(sprite_index);
var _sh = sprite_get_height(sprite_index);

// Escala minima para cubrir la vista con margen
var _s = max(_cw * (1 + margen) / _sw, _ch * (1 + margen) / _sh);
var _dw = _sw * _s;
var _dh = _sh * _s;

// Avance de la camara en la room, cero a uno
var _tx = room_width > _cw ? clamp(_cx / (room_width - _cw), 0, 1) : 0.5;
var _ty = room_height > _ch ? clamp(_cy / (room_height - _ch), 0, 1) : 0.5;

// El fondo acompana a la camara y se desliza
var _x = _cx - (_dw - _cw) * _tx + sprite_get_xoffset(sprite_index) * _s;
var _y = _cy - (_dh - _ch) * _ty + sprite_get_yoffset(sprite_index) * _s;
// Suavizado solo para el fondo, no los personajes
gpu_set_texfilter(true);
draw_sprite_ext(sprite_index, 0, _x, _y, _s, _s, 0, c_white, 1);
gpu_set_texfilter(false);
