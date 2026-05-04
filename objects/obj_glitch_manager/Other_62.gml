// obj_glitch_manager — Async HTTP Event (Other > HTTP)
// Handles all HTTP responses from the Glitch API.
// Defensive version: ignores malformed async payloads and missing request IDs.

if (!ds_exists(async_load, ds_type_map)) exit;

var _id     = ds_map_exists(async_load, "id") ? ds_map_find_value(async_load, "id") : -1;
var _result = ds_map_exists(async_load, "result") ? ds_map_find_value(async_load, "result") : "";

// Newer GameMaker runtimes include http_status for the real HTTP code.
// Some examples/older runtimes only expose status, where 0 means transport success.
var _code = -1;
if (ds_map_exists(async_load, "http_status")) {
    _code = ds_map_find_value(async_load, "http_status");
} else if (ds_map_exists(async_load, "status")) {
    _code = ds_map_find_value(async_load, "status");
    if (_code == 0) _code = 200;
}

if (is_undefined(_id)) _id = -1;
if (is_undefined(_code)) _code = -1;
if (is_undefined(_result)) _result = "";
if (!is_real(_code)) _code = -1;
if (!is_string(_result)) _result = string(_result);

if (!variable_instance_exists(id, "validation_req")) validation_req = -1;
if (!variable_instance_exists(id, "heartbeat_req")) heartbeat_req = -1;
if (!variable_instance_exists(id, "achievement_req")) achievement_req = -1;
if (!variable_instance_exists(id, "leaderboard_req")) leaderboard_req = -1;
if (!variable_instance_exists(id, "cloud_save_req")) cloud_save_req = -1;
if (!variable_instance_exists(id, "cloud_load_req")) cloud_load_req = -1;
if (!variable_instance_exists(id, "progression_req")) progression_req = -1;

if (!variable_global_exists("glitch_validated")) global.glitch_validated = false;
if (!variable_global_exists("glitch_player_name")) global.glitch_player_name = "Guest";
if (!variable_global_exists("glitch_enforce_validation")) global.glitch_enforce_validation = false;
if (!variable_global_exists("glitch_cloud_response")) global.glitch_cloud_response = "";
if (!variable_global_exists("glitch_leaderboard_response")) global.glitch_leaderboard_response = "";
if (!variable_global_exists("glitch_progression_response")) global.glitch_progression_response = "";
if (!variable_global_exists("glitch_ach_cache") || !ds_exists(global.glitch_ach_cache, ds_type_map)) global.glitch_ach_cache = ds_map_create();
if (!variable_global_exists("glitch_save_versions") || !ds_exists(global.glitch_save_versions, ds_type_map)) global.glitch_save_versions = ds_map_create();
if (!variable_global_exists("glitch_pending_progression_reqs") || !ds_exists(global.glitch_pending_progression_reqs, ds_type_map)) global.glitch_pending_progression_reqs = ds_map_create();
if (!variable_global_exists("glitch_pending_leaderboard_reqs") || !ds_exists(global.glitch_pending_leaderboard_reqs, ds_type_map)) global.glitch_pending_leaderboard_reqs = ds_map_create();
if (!variable_global_exists("glitch_pending_achievement_reqs") || !ds_exists(global.glitch_pending_achievement_reqs, ds_type_map)) global.glitch_pending_achievement_reqs = ds_map_create();

// ═══════════════════════════════════════════════════════════════════════════════
//  VALIDATION RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (validation_req != -1 && _id == validation_req) {
    var _proceed = false;

    if (_code == 200) {
        global.glitch_validated = true;

        if (_result != "") {
            try {
                var _data = json_decode(_result);
                if (ds_exists(_data, ds_type_map)) {
                    if (ds_map_exists(_data, "user_name")) {
                        var _name = ds_map_find_value(_data, "user_name");
                        if (!is_undefined(_name) && _name != "") global.glitch_player_name = string(_name);
                    }
                    ds_map_destroy(_data);
                }
            } catch (_err) {
                show_debug_message("Glitch Aegis: WARNING — validation response JSON could not be parsed.");
            }
        }

        show_debug_message("Glitch Aegis: License valid. Welcome, " + string(global.glitch_player_name) + "!");
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

    // Navigate to target room if we should proceed.
    if (_proceed) {
        try {
            _glitch_continue_to_target_room("validation response " + string(_code));
        } catch (_err) {
            show_debug_message("Glitch Aegis: WARNING — could not continue to target room after validation response.");
            show_debug_message("Glitch Aegis: continue error = " + string(_err));
        }
    }

    validation_req = -1;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  HEARTBEAT RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (heartbeat_req != -1 && _id == heartbeat_req) {
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
var _achievement_key = string(_id);
var _is_achievement_response = (achievement_req != -1 && _id == achievement_req);
if (!_is_achievement_response && ds_map_exists(global.glitch_pending_achievement_reqs, _achievement_key)) {
    _is_achievement_response = true;
}

if (_is_achievement_response) {
    if (_code >= 200 && _code < 300 && _result != "") {
        try {
            _glitch_parse_achievements_response(_result);
            show_debug_message("Glitch Aegis: Achievements loaded successfully.");
        } catch (_err) {
            show_debug_message("Glitch Aegis: Achievement response could not be parsed.");
        }
    } else {
        show_debug_message("Glitch Aegis: Achievement load failed (HTTP " + string(_code) + "). Player may be a guest.");
    }

    if (ds_map_exists(global.glitch_pending_achievement_reqs, _achievement_key)) {
        ds_map_delete(global.glitch_pending_achievement_reqs, _achievement_key);
    }
    if (achievement_req != -1 && _id == achievement_req) achievement_req = -1;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  PROGRESSION SUBMIT RESPONSE (Achievements + Leaderboards use same endpoint)
// ═══════════════════════════════════════════════════════════════════════════════
var _progression_key = string(_id);
var _is_progression_response = (progression_req != -1 && _id == progression_req);
if (!_is_progression_response && ds_map_exists(global.glitch_pending_progression_reqs, _progression_key)) {
    _is_progression_response = true;
}

if (_is_progression_response) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Progression run submitted.");
        global.glitch_progression_response = _result;

        if (_result != "") {
            try {
                var _data = json_decode(_result);
                if (ds_exists(_data, ds_type_map)) {
                    var _feedback = -1;
                    if (ds_map_exists(_data, "player_feedback")) {
                        _feedback = ds_map_find_value(_data, "player_feedback");
                    }

                    var _unlocked = -1;
                    if (ds_exists(_feedback, ds_type_map) && ds_map_exists(_feedback, "newly_unlocked")) {
                        _unlocked = ds_map_find_value(_feedback, "newly_unlocked");
                    } else if (ds_map_exists(_data, "newly_unlocked")) {
                        _unlocked = ds_map_find_value(_data, "newly_unlocked");
                    }

                    if (ds_exists(_unlocked, ds_type_list)) {
                        for (var i = 0; i < ds_list_size(_unlocked); i++) {
                            var _ach = ds_list_find_value(_unlocked, i);
                            if (ds_exists(_ach, ds_type_map)) {
                                var _key = "";
                                if (ds_map_exists(_ach, "api_key")) _key = string(ds_map_find_value(_ach, "api_key"));
                                if (_key != "") {
                                    ds_map_replace(global.glitch_ach_cache, _key, "unlocked");
                                    ds_map_replace(global.glitch_ach_cache, _key + "_progress", 1);
                                    show_debug_message("Glitch Aegis: Achievement Unlocked: " + _key);
                                }
                            }
                        }
                    }

                    var _current_stats = -1;
                    if (ds_exists(_feedback, ds_type_map) && ds_map_exists(_feedback, "current_stats")) {
                        _current_stats = ds_map_find_value(_feedback, "current_stats");
                    }

                    // If the API includes stat keys in current_stats, keep the local progress cache fresh.
                    if (ds_exists(_current_stats, ds_type_list)) {
                        for (var j = 0; j < ds_list_size(_current_stats); j++) {
                            var _stat = ds_list_find_value(_current_stats, j);
                            if (ds_exists(_stat, ds_type_map)) {
                                var _stat_key = "";
                                if (ds_map_exists(_stat, "api_key")) _stat_key = string(ds_map_find_value(_stat, "api_key"));
                                if (_stat_key == "" && ds_map_exists(_stat, "key")) _stat_key = string(ds_map_find_value(_stat, "key"));
                                if (_stat_key == "" && ds_map_exists(_stat, "stat_definition")) {
                                    var _def = ds_map_find_value(_stat, "stat_definition");
                                    if (ds_exists(_def, ds_type_map) && ds_map_exists(_def, "api_key")) {
                                        _stat_key = string(ds_map_find_value(_def, "api_key"));
                                    }
                                }
                                if (_stat_key != "" && ds_map_exists(_stat, "current_value")) {
                                    ds_map_replace(global.glitch_ach_cache, _stat_key + "_progress", ds_map_find_value(_stat, "current_value"));
                                }
                            }
                        }
                    }

                    ds_map_destroy(_data);
                }
            } catch (_err) {
                show_debug_message("Glitch Aegis: WARNING — progression response JSON could not be parsed.");
            }
        }
    } else {
        show_debug_message("Glitch Aegis: Progression submit failed (HTTP " + string(_code) + ").");
        global.glitch_progression_response = _result;
    }

    if (ds_map_exists(global.glitch_pending_progression_reqs, _progression_key)) {
        ds_map_delete(global.glitch_pending_progression_reqs, _progression_key);
    }
    if (progression_req != -1 && _id == progression_req) progression_req = -1;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CLOUD SAVE RESPONSE
// ═══════════════════════════════════════════════════════════════════════════════
if (cloud_save_req != -1 && _id == cloud_save_req) {
    if (_code == 200 || _code == 201) {
        if (_result != "") {
            try {
                var _data = json_decode(_result);
                if (ds_exists(_data, ds_type_map)) {
                    if (ds_map_exists(_data, "data")) {
                        var _inner = ds_map_find_value(_data, "data");
                        if (ds_exists(_inner, ds_type_map) && ds_map_exists(_inner, "version")) {
                            var _ver = ds_map_find_value(_inner, "version");
                            show_debug_message("Glitch Aegis: Cloud save OK. New version: " + string(_ver));
                        } else {
                            show_debug_message("Glitch Aegis: Cloud save OK.");
                        }
                    } else {
                        show_debug_message("Glitch Aegis: Cloud save OK.");
                    }
                    ds_map_destroy(_data);
                } else {
                    show_debug_message("Glitch Aegis: Cloud save OK.");
                }
            } catch (_err) {
                show_debug_message("Glitch Aegis: Cloud save OK, but response JSON could not be parsed.");
            }
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
if (cloud_load_req != -1 && _id == cloud_load_req) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Cloud saves downloaded. Use glitch_cloud_parse_slot() to extract data.");
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
var _leaderboard_key = string(_id);
var _is_leaderboard_response = (leaderboard_req != -1 && _id == leaderboard_req);
if (!_is_leaderboard_response && ds_map_exists(global.glitch_pending_leaderboard_reqs, _leaderboard_key)) {
    _is_leaderboard_response = true;
}

if (_is_leaderboard_response) {
    if (_code >= 200 && _code < 300) {
        show_debug_message("Glitch Aegis: Leaderboard data received.");
        global.glitch_leaderboard_response = _result;
    } else {
        show_debug_message("Glitch Aegis: Leaderboard download failed (HTTP " + string(_code) + ").");
        global.glitch_leaderboard_response = "";
    }

    if (ds_map_exists(global.glitch_pending_leaderboard_reqs, _leaderboard_key)) {
        ds_map_delete(global.glitch_pending_leaderboard_reqs, _leaderboard_key);
    }
    if (leaderboard_req != -1 && _id == leaderboard_req) leaderboard_req = -1;
}
