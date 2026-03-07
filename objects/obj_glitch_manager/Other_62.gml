// obj_glitch_manager — Async HTTP Event (Other > HTTP)
// ──────────────────────────────────────────────────────
// Handles all HTTP responses from the Glitch API.
// Fires automatically whenever an http_request() completes.

var _id     = ds_map_find_value(async_load, "id");
var _code   = ds_map_find_value(async_load, "http_status");
var _result = ds_map_find_value(async_load, "result");

// ── Handle Validation Response ────────────────────────────────────────────────
if (_id == validation_req) {
    
    if (_code == 200) {
        // Parse the response body for license details
        var _data = json_decode(_result);
        var _is_valid = false;
        
        if (ds_exists(_data, ds_type_map) && ds_map_exists(_data, "valid")) {
            _is_valid = ds_map_find_value(_data, "valid");
        }
        ds_map_destroy(_data);
        
        global.glitch_validated = true;
        
        if (_is_valid) {
            // ✅ Valid license — proceed to the game
            show_debug_message("Glitch Aegis: License validated. Proceeding to game.");
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) {
                room_goto(_target_asset);
            } else {
                show_debug_message("Glitch Aegis: WARNING — Target room '" + _target_name + "' not found. Staying in init room.");
            }
        } else {
            // Server returned 200 but valid=false
            if (global.glitch_enforce_validation) {
                glitch_show_error("Your license could not be verified.\n\nPlease launch this game from Glitch.fun\nto access your valid session.");
            } else {
                show_debug_message("Glitch Aegis: Validation returned valid=false (EnforceValidation OFF — continuing).");
                var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
                var _target_asset = asset_get_index(_target_name);
                if (room_exists(_target_asset)) { room_goto(_target_asset); }
            }
        }
        
    } else if (_code == 403) {
        // ❌ Forbidden — session is invalid or expired
        if (global.glitch_enforce_validation) {
            glitch_show_error("Access Denied (403 Forbidden).\n\nThis session is not authorized or has expired.\nPlease launch this game from Glitch.fun.");
        } else {
            show_debug_message("Glitch Aegis: Validation returned 403 (EnforceValidation OFF — continuing).");
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) { room_goto(_target_asset); }
        }
        
    } else if (_code == 401) {
        // ❌ Unauthorized — bad token
        show_debug_message("Glitch Aegis: Validation returned 401 Unauthorized. Check your Title Token.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Authorization Error (401).\n\nYour Title Token may be invalid.\nCheck your Glitch Developer Dashboard.");
        } else {
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) { room_goto(_target_asset); }
        }
        
    } else if (_code == 422) {
        // ❌ Unprocessable — malformed request
        show_debug_message("Glitch Aegis: Validation returned 422. Check Title ID and install_id format.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Configuration Error (422).\n\nCheck your Title ID in the Extension Options.\nContact support at glitch.fun if this persists.");
        } else {
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) { room_goto(_target_asset); }
        }
        
    } else if (_code == 0 || _code == -1) {
        // ❌ No response — network error or no internet
        show_debug_message("Glitch Aegis: Validation failed — network error or no internet connection.");
        if (global.glitch_enforce_validation) {
            glitch_show_error("Could not connect to Glitch servers.\n\nPlease check your internet connection\nand try again.");
        } else {
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) { room_goto(_target_asset); }
        }
        
    } else {
        // ❌ Other unexpected status
        show_debug_message("Glitch Aegis: Unexpected validation status: " + string(_code));
        if (!global.glitch_enforce_validation) {
            var _target_name  = extension_get_option_value("GlitchAegis", "target_room");
            var _target_asset = asset_get_index(_target_name);
            if (room_exists(_target_asset)) { room_goto(_target_asset); }
        }
    }
    
    validation_req = -1; // Clear so we don't double-process
}

// ── Handle Heartbeat Response (optional logging) ──────────────────────────────
if (_id == heartbeat_req) {
    if (_code == 200 || _code == 201) {
        show_debug_message("Glitch Aegis: Heartbeat OK (" + string(_code) + ").");
    } else {
        show_debug_message("Glitch Aegis: Heartbeat returned HTTP " + string(_code) + ".");
    }
    heartbeat_req = -1;
}
