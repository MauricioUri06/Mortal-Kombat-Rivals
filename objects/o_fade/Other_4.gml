// En el cuarto nuevo empieza a aclarar
if (estado == "cambiando") estado = "aclarar";
// Si el nivel no tiene o_control, se crea
if (!instance_exists(o_control)) instance_create_depth(0, 0, 0, o_control);
