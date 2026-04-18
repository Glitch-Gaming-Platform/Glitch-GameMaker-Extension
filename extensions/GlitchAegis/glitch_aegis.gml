// =============================================================================
// Glitch Aegis Extension v3.0 — GML Functions
// https://github.com/Glitch-Gaming-Platform/Glitch-GameMaker-Extension
// =============================================================================
// Features: Heartbeat/Payouts, DRM, Achievements, Leaderboards,
//           Cloud Saves, Analytics, Steam-to-Glitch Bridge
// =============================================================================


// =============================================================================
//  0. OPTION NORMALIZATION HELPERS
// =============================================================================

#define _glitch_option_string_or_empty
/// @description Reads a GlitchAegis extension option and returns a safe string.
///              Non-string/object-like values are normalized to "".
/// @param {string} _name
/// @returns {string}

var _name = argument0;
var _raw  = extension_get_option_value("GlitchAegis", _name);

if (is_string(_raw)) {
    return string_trim(_raw);
}

if (is_real(_raw)) {
    // In affected HTML5 builds, empty string options have sometimes arrived as 0.
    if (_raw == 0) return "";
    return string(_raw);
}

if (is_bool(_raw)) {
    return _raw ? "true" : "";
}

// Do not attempt to stringify arrays / structs / undefined-like values.
return "";


#define _glitch_option_string
/// @description Reads a GlitchAegis extension option as a safe string with fallback.
/// @param {string} _name
/// @param {string} _default
/// @returns {string}

var _name    = argument0;
var _default = argument1;

var _value = _glitch_option_string_or_empty(_name);
if (_value != "") return _value;
return _default;


#define _glitch_option_bool
/// @description Reads a GlitchAegis extension option as a bool with fallback.
/// @param {string} _name
/// @param {bool} _default
/// @returns {bool}

var _name    = argument0;
var _default = argument1;
var _raw     = extension_get_option_value("GlitchAegis", _name);

if (is_bool(_raw)) return _raw;
if (is_real(_raw)) return (_raw != 0);

if (is_string(_raw)) {
    var _text = string_lower(string_trim(_raw));
    return (_text == "true" || _text == "1" || _text == "yes");
}

return _default;


#define _glitch_clean_runtime_string
/// @description Normalizes runtime values such as query params / env vars to a safe string.
/// @param {*} _value
/// @returns {string}

var _value = argument0;

if (is_string(_value)) {
    return string_trim(_value);
}

if (is_real(_value)) {
    if (_value == 0) return "";
    return string(_value);
}

if (is_bool(_value)) {
    return _value ? "true" : "";
}

return "";


// =============================================================================
//  1. INITIALIZATION
// =============================================================================

#define glitch_init
/// @description Initializes the Glitch Aegis system. Called automatically by obj_glitch_manager.
///              Reads extension options and detects the player's install_id.

// --- Load extension options ---
global.glitch_title_id           = _glitch_option_string("title_id", "");
global.glitch_token              = _glitch_option_string("title_token", "");
global.glitch_auto_heartbeat     = _glitch_option_bool("enable_auto_heartbeat", true);
global.glitch_enforce_validation = _glitch_option_bool("enforce_validation", false);
global.glitch_enable_ach         = _glitch_option_bool("enable_achievements", true);
global.glitch_enable_lb          = _glitch_option_bool("enable_leaderboards", true);
global.glitch_enable_cloud       = _glitch_option_bool("enable_cloud_saves", true);
global.glitch_enable_steam       = _glitch_option_bool("enable_steam_bridge", false);

// --- Runtime state ---
global.glitch_install_id    = "";
global.glitch_validated     = false;
global.glitch_player_name   = "Guest";
global.glitch_error_active  = false;
global.glitch_error_message = "";
global.glitch_base_url      = "https://api.glitch.fun/api/";

// --- Achievement cache ---
global.glitch_ach_cache  = ds_map_create();  // api_key -> ds_map { status, progress, threshold, name }
global.glitch_ach_loaded = false;

// --- Cloud save version tracking ---
global.glitch_save_versions = ds_map_create();  // slot_index -> version number

// --- Steam bridge pending state ---
global.glitch_steam_pending_stats  = ds_map_create();
global.glitch_steam_pending_scores = ds_map_create();

// --- Step 1: Check DevTestInstallId ---
var _dev_id = _glitch_option_string_or_empty("dev_test_install_id");
if (_dev_id != "") {
    global.glitch_install_id = _dev_id;
    show_debug_message("Glitch Aegis [DEV]: Using DevTestInstallId = " + string(_dev_id));
    return;
}

// --- Step 2: Detect install_id ---
// Use GameMaker's built-in parameter APIs for both desktop and HTML5.
// On HTML5, parameter_count()/parameter_string() expose URL query parameters.
var _count = parameter_count();
for (var i = 1; i <= _count; i++) {
    var _param = _glitch_clean_runtime_string(parameter_string(i));
    if (_param == "") continue;

    // HTML5/GX-style query parameters typically arrive as key=value
    if (string_pos("install_id=", _param) == 1) {
        global.glitch_install_id = _glitch_clean_runtime_string(
            string_delete(_param, 1, string_length("install_id="))
        );
        break;
    }

    // Be tolerant of a leading ? if the runner includes it
    if (string_pos("?install_id=", _param) == 1) {
        global.glitch_install_id = _glitch_clean_runtime_string(
            string_delete(_param, 1, string_length("?install_id="))
        );
        break;
    }

    // Desktop CLI-style launch arguments: --install_id VALUE
    if ((_param == "--install_id" || _param == "install_id") && i < _count) {
        global.glitch_install_id = _glitch_clean_runtime_string(parameter_string(i + 1));
        break;
    }
}

// Also check environment variable on native targets
if (global.glitch_install_id == "") {
    var _env = _glitch_clean_runtime_string(environment_get_variable("GLITCH_INSTALL_ID"));
    if (_env != "") global.glitch_install_id = _env;
}

if (global.glitch_install_id != "") {
    show_debug_message("Glitch Aegis: install_id = " + string(global.glitch_install_id));
} else {
    show_debug_message("Glitch Aegis: No install_id found.");
}


// =============================================================================
//  INTERNAL HELPER: Build authorization headers
// =============================================================================


#define _glitch_headers
/// @description Creates a ds_map with Authorization and Content-Type headers.
/// @returns {ds_map} Headers map (caller must destroy it)

var _h = ds_map_create();
ds_map_add(_h, "Authorization", "Bearer " + global.glitch_token);
ds_map_add(_h, "Content-Type",  "application/json");
return _h;


// =============================================================================
//  2. HEARTBEAT (Payouts)
// =============================================================================

#define glitch_send_heartbeat
/// @description Sends a 60-second playtime heartbeat. Returns HTTP request ID.

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Heartbeat skipped — no install_id.");
    return -1;
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id + "/installs";
var _headers = _glitch_headers();
var _body = ds_map_create();
ds_map_add(_body, "user_install_id", global.glitch_install_id);
ds_map_add(_body, "platform", (os_browser != browser_not_a_browser) ? "web" : "pc");
var _req = http_request(_url, "POST", _headers, json_encode(_body));
ds_map_destroy(_headers);
ds_map_destroy(_body);
return _req;


// =============================================================================
//  3. DRM VALIDATION
// =============================================================================

#define glitch_validate_license
/// @description Validates the player's Glitch license. Returns HTTP request ID.

if (global.glitch_install_id == "") {
    if (global.glitch_enforce_validation) {
        glitch_show_error("This game must be launched from Glitch.fun.\n\nNo valid session was found.\nPlease visit glitch.fun to play.");
    }
    show_debug_message("Glitch Aegis: Validation skipped — no install_id.");
    return -1;
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id + "/installs/" + global.glitch_install_id + "/validate";
var _headers = _glitch_headers();
var _req = http_request(_url, "POST", _headers, "");
ds_map_destroy(_headers);
return _req;


// =============================================================================
//  4. ACHIEVEMENTS
// =============================================================================

#define glitch_load_achievements
/// @description Downloads the player's achievement list from the server.
///              Results arrive in the Async HTTP Event. Returns request ID.

if (global.glitch_install_id == "") return -1;

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/installs/" + global.glitch_install_id + "/achievements";
var _headers = _glitch_headers();
var _req = http_request(_url, "GET", _headers, "");
ds_map_destroy(_headers);
show_debug_message("Glitch Aegis: Loading achievements...");
return _req;


#define glitch_report_achievement
/// @description Reports progress toward an achievement.
///              If the progress meets the threshold, Glitch unlocks it automatically.
///              The Aegis Bridge overlay shows a toast notification on unlock.
/// @param {string} _api_key  The achievement nickname from the dashboard (e.g. "boss_killed")
/// @param {real}   _value    The progress value to report. Use 1 for simple unlocks.
/// @returns {real} HTTP request ID, or -1 if no session

var _api_key = argument0;
var _value   = argument1;

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Cannot report achievement — no install_id.");
    return -1;
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/installs/" + global.glitch_install_id + "/submit";
var _headers = _glitch_headers();

// Build the stats payload
var _stats = ds_map_create();
ds_map_add(_stats, _api_key, _value);
var _payload = ds_map_create();
ds_map_add(_payload, "stats", _stats);
var _body = ds_map_create();
ds_map_add(_body, "idempotency_key", _glitch_uuid());
ds_map_add(_body, "payload", _payload);

var _json = json_encode(_body);
var _req = http_request(_url, "POST", _headers, _json);

ds_map_destroy(_headers);
// Note: json_encode handles nested maps, but we must still clean up
ds_map_destroy(_stats);
ds_map_destroy(_payload);
ds_map_destroy(_body);

show_debug_message("Glitch Aegis: Achievement progress sent: " + _api_key + " = " + string(_value));
return _req;


#define glitch_is_achievement_unlocked
/// @description Checks if an achievement is unlocked (uses local cache, instant).
/// @param {string} _api_key  The achievement API key
/// @returns {bool} true if unlocked

var _api_key = argument0;
if (ds_map_exists(global.glitch_ach_cache, _api_key)) {
    var _ach = ds_map_find_value(global.glitch_ach_cache, _api_key);
    if (is_string(_ach)) {
        // Simple string status
        return (_ach == "unlocked");
    }
}
return false;


#define glitch_get_achievement_progress
/// @description Gets the progress value of an achievement (local cache).
/// @param {string} _api_key  The achievement API key
/// @returns {real} Progress value, or 0 if not found

var _api_key = argument0;
var _key = _api_key + "_progress";
if (ds_map_exists(global.glitch_ach_cache, _key)) {
    return ds_map_find_value(global.glitch_ach_cache, _key);
}
return 0;


// =============================================================================
//  5. LEADERBOARDS
// =============================================================================

#define glitch_submit_score
/// @description Submits a score to a leaderboard.
/// @param {string} _board_key  The leaderboard API key from the dashboard (e.g. "high_score")
/// @param {real}   _score      The numeric score to submit
/// @returns {real} HTTP request ID

var _board_key = argument0;
var _score     = argument1;

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Cannot submit score — no install_id.");
    return -1;
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/installs/" + global.glitch_install_id + "/submit";
var _headers = _glitch_headers();

var _scores = ds_map_create();
ds_map_add(_scores, _board_key, _score);
var _payload = ds_map_create();
ds_map_add(_payload, "scores", _scores);
var _body = ds_map_create();
ds_map_add(_body, "idempotency_key", _glitch_uuid());
ds_map_add(_body, "payload", _payload);

var _json = json_encode(_body);
var _req = http_request(_url, "POST", _headers, _json);

ds_map_destroy(_headers);
ds_map_destroy(_scores);
ds_map_destroy(_payload);
ds_map_destroy(_body);

show_debug_message("Glitch Aegis: Score submitted: " + _board_key + " = " + string(_score));
return _req;


#define glitch_get_leaderboard
/// @description Downloads leaderboard entries for a given board.
///              Results arrive in the Async HTTP Event.
/// @param {string} _board_key  The leaderboard API key (e.g. "high_score")
/// @returns {real} HTTP request ID

var _board_key = argument0;

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/leaderboards/" + _board_key;
var _headers = _glitch_headers();
var _req = http_request(_url, "GET", _headers, "");
ds_map_destroy(_headers);
show_debug_message("Glitch Aegis: Downloading leaderboard: " + _board_key);
return _req;


// =============================================================================
//  6. CLOUD SAVES
// =============================================================================

#define glitch_cloud_save
/// @description Saves game data to a Glitch cloud slot.
///              Uses buffer-based serialization for maximum compatibility.
/// @param {real}   _slot   Slot number (0-99)
/// @param {string} _data   JSON string of the data you want to save
/// @returns {real} HTTP request ID

var _slot = argument0;
var _data = argument1;

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Cannot cloud save — no install_id.");
    return -1;
}

// Base64 encode the data
var _base64 = base64_encode(_data);

// Simple checksum (hash of the raw data)
var _checksum = md5_string_utf8(_data);

// Get base_version from local tracking
var _base_version = 0;
if (ds_map_exists(global.glitch_save_versions, _slot)) {
    _base_version = ds_map_find_value(global.glitch_save_versions, _slot);
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/installs/" + global.glitch_install_id + "/saves";
var _headers = _glitch_headers();

var _body = ds_map_create();
ds_map_add(_body, "slot_index", _slot);
ds_map_add(_body, "payload", _base64);
ds_map_add(_body, "checksum", _checksum);
ds_map_add(_body, "base_version", _base_version);
ds_map_add(_body, "save_type", "manual");
ds_map_add(_body, "client_timestamp", date_datetime_string(date_current_datetime()));

var _req = http_request(_url, "POST", _headers, json_encode(_body));
ds_map_destroy(_headers);
ds_map_destroy(_body);

show_debug_message("Glitch Aegis: Cloud save to slot " + string(_slot) + " (base_version " + string(_base_version) + ")");
return _req;


#define glitch_cloud_save_map
/// @description Convenience: saves a ds_map to a Glitch cloud slot.
///              Automatically encodes the map to JSON.
/// @param {real}   _slot  Slot number (0-99)
/// @param {ds_map} _map   The ds_map to save
/// @returns {real} HTTP request ID

var _slot = argument0;
var _map  = argument1;
var _json = json_encode(_map);
return glitch_cloud_save(_slot, _json);


#define glitch_cloud_load
/// @description Downloads all cloud save slots. The response arrives in Async HTTP.
///              Parse the response to find your slot by slot_index.
/// @returns {real} HTTP request ID

if (global.glitch_install_id == "") {
    show_debug_message("Glitch Aegis: Cannot cloud load — no install_id.");
    return -1;
}

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
         + "/installs/" + global.glitch_install_id + "/saves";
var _headers = _glitch_headers();
var _req = http_request(_url, "GET", _headers, "");
ds_map_destroy(_headers);
show_debug_message("Glitch Aegis: Loading cloud saves...");
return _req;


#define glitch_cloud_parse_slot
/// @description Helper: Extracts a specific slot from the cloud save response JSON.
///              Returns the decoded payload string, or "" if the slot is empty.
/// @param {string} _response_json  The raw JSON body from the Async HTTP event
/// @param {real}   _slot_index     The slot number to find
/// @returns {string} The decoded save data, or "" if not found

var _response_json = argument0;
var _slot_index    = argument1;

var _data = json_decode(_response_json);
if (!ds_exists(_data, ds_type_map)) return "";

// The response is { "data": [ ... ] }
if (!ds_map_exists(_data, "data")) { ds_map_destroy(_data); return ""; }

var _list = ds_map_find_value(_data, "data");
if (!ds_exists(_list, ds_type_list)) { ds_map_destroy(_data); return ""; }

var _result = "";
for (var i = 0; i < ds_list_size(_list); i++) {
    var _item = ds_list_find_value(_list, i);
    if (ds_exists(_item, ds_type_map)) {
        var _idx = ds_map_find_value(_item, "slot_index");
        if (_idx == _slot_index) {
            // Track version for future saves
            var _ver = ds_map_find_value(_item, "version");
            ds_map_replace(global.glitch_save_versions, _slot_index, _ver);
            
            // Decode the base64 payload
            var _payload = ds_map_find_value(_item, "payload");
            if (is_string(_payload) && _payload != "") {
                _result = base64_decode(_payload);
            }
            break;
        }
    }
}

ds_map_destroy(_data);
return _result;


// =============================================================================
//  7. ANALYTICS EVENTS
// =============================================================================

#define glitch_track_event
/// @description Tracks an in-game behavioral event.
/// @param {string} _step_key   Where it happened (e.g. "level_1", "boss_fight")
/// @param {string} _action_key What happened (e.g. "player_death", "completed")
/// @returns {real} HTTP request ID

var _step_key   = argument0;
var _action_key = argument1;

if (global.glitch_install_id == "") return -1;

var _url = global.glitch_base_url + "titles/" + global.glitch_title_id + "/events";
var _headers = _glitch_headers();
var _body = ds_map_create();
ds_map_add(_body, "game_install_id", global.glitch_install_id);
ds_map_add(_body, "step_key",        _step_key);
ds_map_add(_body, "action_key",      _action_key);
ds_map_add(_body, "event_timestamp", date_datetime_string(date_current_datetime()));
var _req = http_request(_url, "POST", _headers, json_encode(_body));
ds_map_destroy(_headers);
ds_map_destroy(_body);
return _req;


// =============================================================================
//  8. STEAM-TO-GLITCH BRIDGE
// =============================================================================

#define glitch_steam_set_achievement
/// @description Drop-in replacement for steam_set_achievement().
///              Buffers the achievement until glitch_steam_store_stats() is called.
/// @param {string} _api_name  The achievement API name (must match Glitch dashboard key)

var _api_name = argument0;
ds_map_replace(global.glitch_steam_pending_stats, _api_name, 100);
show_debug_message("Glitch Steam Bridge: SetAchievement('" + _api_name + "') buffered.");


#define glitch_steam_set_stat_int
/// @description Drop-in replacement for steam_set_stat_int().
/// @param {string} _stat_name  The stat name
/// @param {real}   _value      The value

var _stat_name = argument0;
var _value     = argument1;
ds_map_replace(global.glitch_steam_pending_stats, _stat_name, _value);


#define glitch_steam_set_stat_float
/// @description Drop-in replacement for steam_set_stat_float().
/// @param {string} _stat_name  The stat name
/// @param {real}   _value      The value

var _stat_name = argument0;
var _value     = argument1;
ds_map_replace(global.glitch_steam_pending_stats, _stat_name, _value);


#define glitch_steam_upload_score
/// @description Drop-in replacement for steam_upload_score().
///              Buffers the score until glitch_steam_store_stats() is called.
/// @param {string} _board_key  The leaderboard name (must match Glitch dashboard key)
/// @param {real}   _score      The score to submit

var _board_key = argument0;
var _score     = argument1;
ds_map_replace(global.glitch_steam_pending_scores, _board_key, _score);


#define glitch_steam_get_achievement
/// @description Drop-in replacement for steam_get_achievement().
///              Checks the local Glitch achievement cache.
/// @param {string} _api_name  The achievement API name
/// @returns {bool} true if unlocked

return glitch_is_achievement_unlocked(argument0);


#define glitch_steam_store_stats
/// @description Drop-in replacement for steam_stats_store().
///              Flushes all buffered stats and scores to Glitch.
///              Call this after SetAchievement / SetStat / UploadScore.

// Send achievement stats
if (ds_map_size(global.glitch_steam_pending_stats) > 0) {
    var _url = global.glitch_base_url + "titles/" + global.glitch_title_id
             + "/installs/" + global.glitch_install_id + "/submit";
    var _headers = _glitch_headers();
    
    var _payload = ds_map_create();
    ds_map_add(_payload, "stats", global.glitch_steam_pending_stats);
    var _body = ds_map_create();
    ds_map_add(_body, "idempotency_key", _glitch_uuid());
    ds_map_add(_body, "payload", _payload);
    
    http_request(_url, "POST", _headers, json_encode(_body));
    ds_map_destroy(_headers);
    ds_map_destroy(_payload);
    ds_map_destroy(_body);
    
    // Clear pending
    ds_map_clear(global.glitch_steam_pending_stats);
    show_debug_message("Glitch Steam Bridge: Stats flushed to Glitch.");
}

// Send leaderboard scores
var _key = ds_map_find_first(global.glitch_steam_pending_scores);
while (is_string(_key)) {
    var _score = ds_map_find_value(global.glitch_steam_pending_scores, _key);
    glitch_submit_score(_key, _score);
    _key = ds_map_find_next(global.glitch_steam_pending_scores, _key);
}
ds_map_clear(global.glitch_steam_pending_scores);


#define glitch_steam_request_stats
/// @description Drop-in replacement for steam_stats_request().
///              Refreshes the achievement cache from Glitch.

glitch_load_achievements();


// =============================================================================
//  9. ERROR OVERLAY
// =============================================================================

#define glitch_show_error
/// @description Activates the error overlay.
/// @param {string} _message  The error message

global.glitch_error_active  = true;
global.glitch_error_message = argument0;
show_debug_message("Glitch Aegis ERROR: " + argument0);


#define glitch_dismiss_error
/// @description Dismisses the error overlay (only works if enforce_validation is OFF).

if (!global.glitch_enforce_validation) {
    global.glitch_error_active  = false;
    global.glitch_error_message = "";
}


// =============================================================================
//  10. INTERNAL UTILITIES
// =============================================================================

#define _glitch_uuid
/// @description Generates a simple UUID v4 string for idempotency keys.
/// @returns {string}

var _hex = "0123456789abcdef";
var _uuid = "";
for (var i = 0; i < 32; i++) {
    if (i == 8 || i == 12 || i == 16 || i == 20) _uuid += "-";
    if (i == 12) {
        _uuid += "4";
    } else if (i == 16) {
        _uuid += string_char_at(_hex, (irandom(3) + 8) + 1);
    } else {
        _uuid += string_char_at(_hex, irandom(15) + 1);
    }
}
return _uuid;


#define _glitch_parse_achievements_response
/// @description Internal: Parses the achievements JSON response and populates the cache.
/// @param {string} _json  The raw JSON response body

var _data = json_decode(argument0);
if (!ds_exists(_data, ds_type_map)) return;

var _arr;
if (ds_map_exists(_data, "data")) {
    _arr = ds_map_find_value(_data, "data");
} else {
    ds_map_destroy(_data);
    return;
}

if (!ds_exists(_arr, ds_type_list)) { ds_map_destroy(_data); return; }

ds_map_clear(global.glitch_ach_cache);

for (var i = 0; i < ds_list_size(_arr); i++) {
    var _item = ds_list_find_value(_arr, i);
    if (!ds_exists(_item, ds_type_map)) continue;
    
    var _api_key = "";
    if (ds_map_exists(_item, "api_key")) _api_key = ds_map_find_value(_item, "api_key");
    if (_api_key == "") continue;
    
    var _status = "locked";
    if (ds_map_exists(_item, "status")) _status = ds_map_find_value(_item, "status");
    
    var _progress = 0;
    if (ds_map_exists(_item, "progress_value")) _progress = ds_map_find_value(_item, "progress_value");
    
    // Store status and progress with predictable key names
    ds_map_add(global.glitch_ach_cache, _api_key, _status);
    ds_map_add(global.glitch_ach_cache, _api_key + "_progress", _progress);
}

global.glitch_ach_loaded = true;
ds_map_destroy(_data);
show_debug_message("Glitch Aegis: Achievements cached (" + string(ds_map_size(global.glitch_ach_cache) div 2) + " entries).");
