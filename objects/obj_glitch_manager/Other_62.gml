var _id = ds_map_find_value(async_load, "id");

if (_id == validation_req) {
    var _status = ds_map_find_value(async_load, "status");
    var _code = ds_map_find_value(async_load, "http_status");
    
    if (_code == 200) {
        // Success! Move to the game.
        var _target_name = extension_get_option_value("GlitchAegis", "target_room");
        var _target_asset = asset_get_index(_target_name);
        
        if (room_exists(_target_asset)) {
            room_goto(_target_asset);
        } else {
            show_debug_message("Glitch Aegis: Target room " + _target_name + " not found. Staying in init room.");
        }
    } else if (_code == 403) {
        // Security Failure
        show_message_async("Aegis Security: No valid license found. Please launch from Glitch.");
        game_end();
    }
}
