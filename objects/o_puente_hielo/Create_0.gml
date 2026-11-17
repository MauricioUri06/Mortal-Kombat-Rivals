// Puente de hielo: colocalo sobre el vacio
// Solo se pisa cuando Sub-Zero lo crea
duracion = 1.3; // segundos que dura el puente antes de romperse
aviso = 0.75; // segundos finales en los que parpadea
fps_romper = 4; // velocidad de la animacion al romperse
activo = false;
desde_derecha = false; // true si se forma de derecha a izquierda
desapareciendo = false;
anim = 0;
timer = 0;
solido = noone;
image_speed = 0;
silueta_alpha = 0.3; // transparencia de la silueta antes de crearlo
