event_inherited();
player_number = 2;
character_name = "SCORPION";
fighter_colour = make_colour_rgb(255, 197, 53);
projectile_object = o_spear;
right = false;
spawn_right = false;
key_left = ord("A");
key_right = ord("D");
key_jump = ord("W");
button_punch = mb_left;
button_kick = mb_right;
key_ranged = ord("Q");
key_slide = vk_shift;
key_crouch = ord("S");
sprites = {
    stand: s_scorpion_stand, run: s_scorpion_run,
    jump_start: s_scorpion_jump_start, jump: s_scorpion_jump,
    fall: s_scorpion_fall, land: s_scorpion_land,
    punch: s_scorpion_punch, ranged: s_scorpion_ranged,
    slide: s_scorpion_slide, kick: s_scorpion_kick, crouch: s_scorpion_crouch, hurt: s_scorpion_hurt, death: s_scorpion_death
};
c_fighter_state("stand");
