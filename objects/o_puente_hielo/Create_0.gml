// Puente de hielo: colocalo en la room sobre el vacio, del ancho del hueco.
// Se ve como una silueta transparente y no se puede pisar hasta que Sub-Zero lo crea con E.
// Dura unos segundos y se rompe; despues se puede volver a crear.
duracion = 1.3;          // segundos que dura el puente
aviso = 0.75;          // segundos finales en los que parpadea antes de romperse
fps_romper = 4;        // velocidad de la animacion al romperse (cuadros por segundo; menos = mas lenta)
activo = false;
desde_derecha = false; // true: se forma de derecha a izquierda
desapareciendo = false;
anim = 0;
timer = 0;
solido = noone;
image_speed = 0;
silueta_alpha = 0.3;   // transparencia de la silueta antes de crearlo (0 = invisible)
