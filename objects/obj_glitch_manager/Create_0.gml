// obj_glitch_manager — Create Event
// Defensive startup: never let the Glitch plugin crash the host game.

// 1. Track request IDs first so Async HTTP can safely run even if init fails.
validation_req    = -1;
heartbeat_req     = -1;
achievement_req   = -1;
leaderboard_req   = -1;
cloud_save_req    = -1;
cloud_load_req    = -1;
progression_req   = -1;

// 2. Safe global defaults. These prevent Draw/Alarm/Async events from reading unset globals.
global.glitch_title_id             = variable_global_exists("glitch_title_id") ? global.glitch_title_id : "";
global.glitch_token                = variable_global_exists("glitch_token") ? global.glitch_token : "";
global.glitch_auto_heartbeat       = variable_global_exists("glitch_auto_heartbeat") ? global.glitch_auto_heartbeat : false;
global.glitch_enforce_validation   = variable_global_exists("glitch_enforce_validation") ? global.glitch_enforce_validation : false;
global.glitch_enable_ach           = variable_global_exists("glitch_enable_ach") ? global.glitch_enable_ach : false;
global.glitch_enable_lb            = variable_global_exists("glitch_enable_lb") ? global.glitch_enable_lb : false;
global.glitch_enable_cloud         = variable_global_exists("glitch_enable_cloud") ? global.glitch_enable_cloud : false;
global.glitch_enable_steam         = variable_global_exists("glitch_enable_steam") ? global.glitch_enable_steam : false;
global.glitch_install_id           = variable_global_exists("glitch_install_id") ? global.glitch_install_id : "";
global.glitch_validated            = variable_global_exists("glitch_validated") ? global.glitch_validated : false;
global.glitch_player_name          = variable_global_exists("glitch_player_name") ? global.glitch_player_name : "Guest";
global.glitch_error_active         = variable_global_exists("glitch_error_active") ? global.glitch_error_active : false;
global.glitch_error_message        = variable_global_exists("glitch_error_message") ? global.glitch_error_message : "";
global.glitch_base_url             = variable_global_exists("glitch_base_url") ? global.glitch_base_url : "https://api.glitch.fun/api/";
global.glitch_cloud_response       = variable_global_exists("glitch_cloud_response") ? global.glitch_cloud_response : "";
global.glitch_leaderboard_response = variable_global_exists("glitch_leaderboard_response") ? global.glitch_leaderboard_response : "";

if (!variable_global_exists("glitch_ach_cache") || !ds_exists(global.glitch_ach_cache, ds_type_map)) {
    global.glitch_ach_cache = ds_map_create();
}
if (!variable_global_exists("glitch_save_versions") || !ds_exists(global.glitch_save_versions, ds_type_map)) {
    global.glitch_save_versions = ds_map_create();
}
if (!variable_global_exists("glitch_steam_pending_stats") || !ds_exists(global.glitch_steam_pending_stats, ds_type_map)) {
    global.glitch_steam_pending_stats = ds_map_create();
}
if (!variable_global_exists("glitch_steam_pending_scores") || !ds_exists(global.glitch_steam_pending_scores, ds_type_map)) {
    global.glitch_steam_pending_scores = ds_map_create();
}

// 3. Initialize extension. If the extension function is missing/misregistered, do not crash the game.
var _glitch_ready = false;
if (extension_exists("GlitchAegis")) {
    try {
        glitch_init();
        _glitch_ready = true;
    } catch (_err) {
        show_debug_message("Glitch Aegis: WARNING — glitch_init() failed or was not registered. Continuing without Glitch services.");
        global.glitch_error_active = false;
    }
} else {
    show_debug_message("Glitch Aegis: WARNING — Extension asset 'GlitchAegis' not found. Continuing without Glitch services.");
}

// 4. Validate the player's license.
if (_glitch_ready) {
    try {
        validation_req = glitch_validate_license();
    } catch (_err) {
        validation_req = -1;
        show_debug_message("Glitch Aegis: WARNING — validation skipped because glitch_validate_license() failed.");
    }
}

// 5. Start auto-heartbeat.
if (_glitch_ready && global.glitch_auto_heartbeat) {
    try {
        heartbeat_req = glitch_send_heartbeat();
        alarm[0] = 60 * game_get_speed(gamespeed_fps);
    } catch (_err) {
        heartbeat_req = -1;
        alarm[0] = -1;
        show_debug_message("Glitch Aegis: WARNING — heartbeat startup failed. Continuing without auto-heartbeat.");
    }
}

// 6. Load achievements if enabled.
if (_glitch_ready && global.glitch_enable_ach && global.glitch_install_id != "") {
    try {
        achievement_req = glitch_load_achievements();
    } catch (_err) {
        achievement_req = -1;
        show_debug_message("Glitch Aegis: WARNING — achievement load skipped because glitch_load_achievements() failed.");
    }
}

// 7. Log Steam Bridge status.
if (_glitch_ready && global.glitch_enable_steam) {
    show_debug_message("Glitch Aegis: Steam-to-Glitch Bridge ENABLED.");
    show_debug_message("  Use glitch_steam_set_achievement() instead of steam_set_achievement()");
    show_debug_message("  Use glitch_steam_upload_score() instead of steam_upload_score()");
    show_debug_message("  Use glitch_steam_store_stats() instead of steam_stats_store()");
}
