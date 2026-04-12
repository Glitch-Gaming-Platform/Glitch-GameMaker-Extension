// obj_glitch_manager — Create Event
// ─────────────────────────────────
// Initializes Aegis, validates license, starts heartbeat,
// loads achievements, and enables the Steam bridge.

// 1. Initialize — reads options, detects install_id
glitch_init();

// 2. Track request IDs for async response handling
validation_req    = -1;
heartbeat_req     = -1;
achievement_req   = -1;
leaderboard_req   = -1;
cloud_save_req    = -1;
cloud_load_req    = -1;
progression_req   = -1;

// 3. Validate the player's license
validation_req = glitch_validate_license();

// 4. Start auto-heartbeat
if (global.glitch_auto_heartbeat) {
    heartbeat_req = glitch_send_heartbeat();
    alarm[0] = 60 * room_speed;
}

// 5. Load achievements if enabled
if (global.glitch_enable_ach && global.glitch_install_id != "") {
    achievement_req = glitch_load_achievements();
}

// 6. Log Steam Bridge status
if (global.glitch_enable_steam) {
    show_debug_message("Glitch Aegis: Steam-to-Glitch Bridge ENABLED.");
    show_debug_message("  Use glitch_steam_set_achievement() instead of steam_set_achievement()");
    show_debug_message("  Use glitch_steam_upload_score() instead of steam_upload_score()");
    show_debug_message("  Use glitch_steam_store_stats() instead of steam_stats_store()");
}
