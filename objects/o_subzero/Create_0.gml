event_inherited();
player_number = 1;
character_name = "SUB-ZERO";
fighter_colour = make_colour_rgb(72, 201, 255);
projectile_object = o_iceball;
sprites = {
    stand: s_subzero_stand, run: s_subzero_run,
    jump_start: s_subzero_jump_start, jump: s_subzero_jump,
    fall: s_subzero_fall, land: s_subzero_land,
    punch: s_subzero_punch, ranged: s_subzero_ranged,
    slide: s_subzero_slide, kick: s_subzero_kick, crouch: s_subzero_crouch, hurt: s_subzero_hurt, death: s_subzero_death,
    defeat: s_subzero_defeat, fatality: s_subzero_fatality,
    wall: s_animacion_wallJump_sz
};
fatality_distance = 87; // distancia del rival para que encaje la escena del fatality
c_fighter_state("stand");
