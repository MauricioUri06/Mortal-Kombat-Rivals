enum MatchMenuAction {
    none = -1,
    resume = 0,
    restart,
    select_fighter,
    main_menu
}

function c_match_menu_open(_menu) {
    match_menu = _menu;
    match_menu_choice = 0;
    match_menu_hover = c_match_menu_find_hover();
}

function c_match_menu_find_hover() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    var _buttons = match_menu_buttons;
    for (var _i = 0; _i < array_length(match_menu.options); _i++) {
        var _top = match_menu.top + _i * _buttons.spacing;
        if (point_in_rectangle(_mx, _my, _buttons.left, _top, _buttons.right, _top + _buttons.height)) {
            return _i;
        }
    }
    return -1;
}

function c_match_menu_input() {
    if (match_menu_action != MatchMenuAction.none) return;
    if (keyboard_check_pressed(vk_escape)) {
        match_menu_action = match_menu.escape_action;
        return;
    }

    var _hover = c_match_menu_find_hover();
    var _click = mouse_check_button_pressed(mb_left);
    if (_hover >= 0 && (_hover != match_menu_hover || _click)) match_menu_choice = _hover;
    match_menu_hover = _hover;

    var _options = match_menu.options;
    var _count = array_length(_options);
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        match_menu_choice = (match_menu_choice + _count - 1) mod _count;
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        match_menu_choice = (match_menu_choice + 1) mod _count;
    }
    if (_click && _hover >= 0) match_menu_action = _options[_hover].action;
    else if (keyboard_check_pressed(vk_enter)) match_menu_action = _options[match_menu_choice].action;
}

function c_match_menu_free_frame() {
    if (surface_exists(match_menu_frame)) surface_free(match_menu_frame);
    match_menu_frame = -1;
}

function c_match_menu_draw() {
    if (!match_menu_frozen) {
        // Captura la arena después de los eventos Draw y antes de ocultar las instancias.
        if (surface_exists(application_surface)) {
            match_menu_frame = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
            if (surface_exists(match_menu_frame)) surface_copy(match_menu_frame, 0, 0, application_surface);
        }
        instance_deactivate_all(true);
        match_menu_frozen = true;
    }

    var _menu = match_menu;
    var _gui_width = display_get_gui_width();
    var _gui_height = display_get_gui_height();
    if (surface_exists(match_menu_frame)) draw_surface_stretched(match_menu_frame, 0, 0, _gui_width, _gui_height);
    draw_set_alpha(0.64);
    draw_set_colour(c_black);
    draw_rectangle(0, 0, _gui_width, _gui_height, false);
    draw_set_alpha(1);
    draw_sprite(s_pause_panel, 0, (_gui_width - sprite_get_width(s_pause_panel)) div 2,
        (_gui_height - sprite_get_height(s_pause_panel)) div 2);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_colour(_menu.accent);
    draw_text_transformed(_gui_width div 2, 268, _menu.title, 2.15, 2.15, 0);
    if (_menu.subtitle != "") {
        draw_set_colour(make_colour_rgb(237, 222, 200));
        draw_text_transformed(_gui_width div 2, 296, _menu.subtitle, 1.1, 1.1, 0);
    }

    var _buttons = match_menu_buttons;
    var _options = _menu.options;
    for (var _i = 0; _i < array_length(_options); _i++) {
        var _top = _menu.top + _i * _buttons.spacing;
        var _bottom = _top + _buttons.height;
        var _selected = _i == match_menu_choice;
        var _border = _selected ? _menu.accent : make_colour_rgb(116, 88, 58);
        var _steel = _selected ? merge_colour(_menu.accent, make_colour_rgb(24, 18, 22), 0.78) : make_colour_rgb(39, 36, 36);
        var _iron = make_colour_rgb(17, 16, 19);
        draw_set_colour(c_black);
        draw_rectangle(_buttons.left - 2, _top - 2, _buttons.right + 2, _bottom + 3, false);
        draw_set_colour(_border);
        draw_rectangle(_buttons.left, _top, _buttons.right, _bottom, false);
        draw_rectangle_colour(_buttons.left + 2, _top + 2, _buttons.right - 2, _bottom - 2,
            _steel, _steel, _iron, _iron, false);
        draw_set_colour(_selected ? make_colour_rgb(255, 232, 189) : make_colour_rgb(219, 207, 188));
        draw_text_transformed(_gui_width div 2, (_top + _bottom) div 2, _options[_i].label, 1.35, 1.35, 0);
    }

    draw_set_colour(make_colour_rgb(178, 160, 137));
    draw_text(_gui_width div 2, 484, _menu.hint);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    if (match_menu_action != MatchMenuAction.none) {
        instance_activate_all();
        match_menu = undefined;
        match_menu_frozen = false;
    }
}
