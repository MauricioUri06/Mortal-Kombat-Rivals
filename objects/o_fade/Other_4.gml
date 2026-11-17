// Room Start: ya en el cuarto nuevo, empieza a aclarar.
if (estado == "cambiando") estado = "aclarar";
// Cada nivel necesita un o_control; si no lo tiene, se crea.
if (!instance_exists(o_control)) instance_create_depth(0, 0, 0, o_control);
