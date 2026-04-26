// obj_glitch_manager — Alarm 0 Event
// Fires every 60 seconds for the playtime heartbeat.

if (!variable_global_exists("glitch_auto_heartbeat") || !global.glitch_auto_heartbeat) exit;

try {
    heartbeat_req = glitch_send_heartbeat();
    alarm[0] = 60 * game_get_speed(gamespeed_fps);
} catch (_err) {
    heartbeat_req = -1;
    alarm[0] = -1;
    show_debug_message("Glitch Aegis: WARNING — heartbeat failed. Auto-heartbeat disabled for this run.");
}
