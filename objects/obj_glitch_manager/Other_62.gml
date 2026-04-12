// obj_glitch_manager — Async HTTP Event (Other > HTTP)
// Handles all HTTP responses from the Glitch API.

var _id     = ds_map_find_value(async_load, "id");
var _code   = ds_map_find_value(async_load, "http_status");
var _result = ds_map_find_value(async_load, "result");


// ═══════════════════════════════════════════════════════════════════════════════
//  VALIDATION RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == validation_req) {
    
    var _proceed = false;
    
    if (_code == 200) {
        global.glitch_validated = true;
        
        // Try to parse player name
        var _data = json_decode(_result);
        if (ds_exists(_data, ds_type_map)) {
            if (ds_map_exists(_data, "user_name")) {
                global.glitch_player_name = ds_map_find_value(_data, "user_name");
            }
            ds_map_destroy(_data);
        }
        
        show_debug_message("Glitch Aegis: License valid. Welcome, " + global.glitch_player_name + "!");
        _proceed = true;
        
    } else if (_code == 403) {
        show_debug_message("Glitch Aegis: Validation returned 403 Forbidden.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Access Denied (403).\n\nThis session is not authorized or has expired.\nPlease launch this game from Glitch.fun.");
        } else {
            _proceed = true;
        }
        
    } else if (_code == 401) {
        show_debug_message("Glitch Aegis: Validation returned 401 Unauthorized.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Authorization Error (401).\n\nYour Title Token may be invalid.\nCheck your Glitch Developer Dashboard.");
        } else {
            _proceed = true;
        }
        
    } else if (_code == 0 || _code == -1) {
        show_debug_message("Glitch Aegis: Validation failed — network error.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Could not connect to Glitch servers.\n\nPlease check your internet connection\nand try again.");
        } else {
            _proceed = true;
        }
        
    } else {
        show_debug_message("Glitch Aegis: Unexpected validation status: " + string(_code));
        if (!global.glitch_enforce_validation) _proceed = true;
    }
    
    // Navigate to target room if we should proceed
    if (_proceed) {
        var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
        var _target_asset = asset_get_index(_target_name);
        if (room_exists(_target_asset)) {
            room_goto(_target_asset);
        } else {
            show_debug_message("Glitch Aegis: WARNING — Target room '" + _target_name + "' not found.");
        }
    }
    
    validation_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  HEARTBEAT RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == heartbeat_req) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Heartbeat OK.");
    } else {
        show_debug_message("Glitch Aegis: Heartbeat returned HTTP " + string(_code) + ".");
    }
    heartbeat_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  ACHIEVEMENT LOAD RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == achievement_req) {
    if (_code >= 200 && _code < 300) {
        _glitch_parse_achievements_response(_result);
        show_debug_message("Glitch Aegis: Achievements loaded successfully.");
    } else {
        show_debug_message("Glitch Aegis: Achievement load failed (HTTP " + string(_code) + "). Player may be a guest.");
    }
    achievement_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  PROGRESSION SUBMIT RESPONSE (Achievements + Leaderboards use the same endpoint)
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == progression_req) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Progression run submitted.");
        
        // Check for newly unlocked achievements in the response
        var _data = json_decode(_result);
        if (ds_exists(_data, ds_type_map) && ds_map_exists(_data, "newly_unlocked")) {
            var _unlocked = ds_map_find_value(_data, "newly_unlocked");
            if (ds_exists(_unlocked, ds_type_list)) {
                for (var i = 0; i < ds_list_size(_unlocked); i++) {
                    var _ach = ds_list_find_value(_unlocked, i);
                    if (ds_exists(_ach, ds_type_map)) {
                        var _key = "";
                        if (ds_map_exists(_ach, "api_key")) _key = ds_map_find_value(_ach, "api_key");
                        if (_key != "") {
                            ds_map_replace(global.glitch_ach_cache, _key, "unlocked");
                            show_debug_message("Glitch Aegis: Achievement Unlocked: " + _key);
                        }
                    }
                }
            }
            ds_map_destroy(_data);
        }
    } else {
        show_debug_message("Glitch Aegis: Progression submit failed (HTTP " + string(_code) + ").");
    }
    progression_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  CLOUD SAVE RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == cloud_save_req) {
    if (_code == 200 || _code == 201) {
        // Parse the new version number
        var _data = json_decode(_result);
        if (ds_exists(_data, ds_type_map)) {
            if (ds_map_exists(_data, "data")) {
                var _inner = ds_map_find_value(_data, "data");
                if (ds_exists(_inner, ds_type_map) && ds_map_exists(_inner, "version")) {
                    var _ver = ds_map_find_value(_inner, "version");
                    // We'd need the slot index to track; for now log success
                    show_debug_message("Glitch Aegis: Cloud save OK. New version: " + string(_ver));
                }
            }
            ds_map_destroy(_data);
        } else {
            show_debug_message("Glitch Aegis: Cloud save OK.");
        }
    } else if (_code == 409) {
        show_debug_message("Glitch Aegis: Cloud save CONFLICT (409). A newer version exists on the server.");
    } else {
        show_debug_message("Glitch Aegis: Cloud save failed (HTTP " + string(_code) + ").");
    }
    cloud_save_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  CLOUD LOAD RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == cloud_load_req) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Cloud saves downloaded. Use glitch_cloud_parse_slot() to extract data.");
        // Store the raw response so game code can parse it
        global.glitch_cloud_response = _result;
    } else {
        show_debug_message("Glitch Aegis: Cloud load failed (HTTP " + string(_code) + ").");
        global.glitch_cloud_response = "";
    }
    cloud_load_req = -1;
}


// ═══════════════════════════════════════════════════════════════════════════════
//  LEADERBOARD DOWNLOAD RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (_id == leaderboard_req) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Leaderboard data received.");
        global.glitch_leaderboard_response = _result;
    } else {
        show_debug_message("Glitch Aegis: Leaderboard download failed (HTTP " + string(_code) + ").");
        global.glitch_leaderboard_response = "";
    }
    leaderboard_req = -1;
}
