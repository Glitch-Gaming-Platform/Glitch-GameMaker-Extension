// =============================================================================
// Glitch Aegis Extension v2.0 — GML Functions
// =============================================================================

#define glitch_init
/// @description Initializes the Glitch Aegis system. Called automatically by obj_glitch_manager.
///              Reads all extension options and detects the player's install_id.

// --- Load extension options into globals ---
global.glitch_title_id           = extension_get_option_value("GlitchAegis", "title_id");
global.glitch_token              = extension_get_option_value("GlitchAegis", "title_token");
global.glitch_auto_heartbeat     = (extension_get_option_value("GlitchAegis", "enable_auto_heartbeat") == "True");
global.glitch_enforce_validation = (extension_get_option_value("GlitchAegis", "enforce_validation") == "True");

// --- Runtime state ---
global.glitch_install_id    = "";
global.glitch_validated     = false;
global.glitch_error_active  = false;
global.glitch_error_message = "";

// --- Step 1: Check DevTestInstallId (overrides everything — for local dev only) ---
var _dev_id = extension_get_option_value("GlitchAegis", "dev_test_install_id");
if (_dev_id != "") {
    global.glitch_install_id = _dev_id;
    show_debug_message("Glitch Aegis [DEV]: Using DevTestInstallId = " + _dev_id);
    return;
}

// --- Step 2: Detect install_id from the environment ---
if (os_browser != browser_not_a_browser) {
    // HTML5 / Web build: read from URL query parameter  ?install_id=XXXX
    global.glitch_install_id = glitch_js_get_url_param("install_id");
} else {
    // Desktop build: read from command-line  --install_id XXXX
    var _count = parameter_count();
    for (var i = 0; i < _count; i++) {
        if (parameter_string(i) == "--install_id" && i + 1 < _count) {
            global.glitch_install_id = parameter_string(i + 1);
        }
    }
}

if (global.glitch_install_id != "") {
    show_debug_message("Glitch Aegis: install_id detected = " + global.glitch_install_id);
} else {
    show_debug_message("Glitch Aegis: No install_id found. Game launched outside Glitch.");
}


// =============================================================================

#define glitch_send_heartbeat
/// @description Sends a 60-second playtime heartbeat to Glitch (earns payout).
///              Returns the HTTP request ID, or -1 if no install_id is available.

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Heartbeat skipped — no install_id.");
    return -1;
}

var _url     = "https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/installs";
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
ds_map_add(_headers, "Content-Type",  "application/json");
var _body = ds_map_create();
ds_map_add(_body, "user_install_id", global.glitch_install_id);
ds_map_add(_body, "platform", (os_browser != browser_not_a_browser) ? "web" : "pc");
var _req = http_request(_url, "POST", _headers, json_encode(_body));
ds_map_destroy(_headers);
ds_map_destroy(_body);
return _req;


// =============================================================================

#define glitch_validate_license
/// @description Validates the player's Glitch license.
///              Returns the HTTP request ID so you can monitor it in the Async HTTP Event.
///              Returns -1 if no install_id found.
///              If EnforceValidation is ON and there is no install_id, shows the error screen immediately.

if (global.glitch_install_id == "") {
    if (global.glitch_enforce_validation) {
        glitch_show_error("This game must be launched from Glitch.fun.\n\nNo valid session was found.\nPlease visit glitch.fun to play.");
    }
    show_debug_message("Glitch Aegis: Validation skipped — no install_id.");
    return -1;
}

var _url     = "https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/installs/" + global.glitch_install_id + "/validate";
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
var _req = http_request(_url, "POST", _headers, "");
ds_map_destroy(_headers);
return _req;


// =============================================================================

#define glitch_track_event
/// @description Tracks an in-game behavioral event for funnel analytics.
/// @param {string} argument0  step_key  — The stage or screen name (e.g. "level_1", "tutorial")
/// @param {string} argument1  action_key — The action taken (e.g. "started", "completed", "died")

var _body = ds_map_create();
ds_map_add(_body, "game_install_id", global.glitch_install_id);
ds_map_add(_body, "step_key",        argument0);
ds_map_add(_body, "action_key",      argument1);
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
ds_map_add(_headers, "Content-Type",  "application/json");
var _req = http_request(
    "https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/events",
    "POST", _headers, json_encode(_body)
);
ds_map_destroy(_headers);
ds_map_destroy(_body);
return _req;


// =============================================================================

#define glitch_show_error
/// @description Activates the Glitch error overlay with a message.
///              If EnforceValidation is ON, the player cannot dismiss it.
/// @param {string} argument0  The error message to display.

global.glitch_error_active  = true;
global.glitch_error_message = argument0;
show_debug_message("Glitch Aegis ERROR: " + argument0);


// =============================================================================

#define glitch_dismiss_error
/// @description Dismisses the Glitch error overlay.
///              Only works when EnforceValidation is OFF.
///              (If EnforceValidation is ON, the overlay cannot be dismissed.)

if (!global.glitch_enforce_validation) {
    global.glitch_error_active  = false;
    global.glitch_error_message = "";
}
