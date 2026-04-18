// obj_glitch_manager — Alarm 0 Event
// Fires every 60 seconds for the playtime heartbeat.

if (global.glitch_auto_heartbeat) {
    heartbeat_req = glitch_send_heartbeat();
    alarm[0] = 60 * game_get_speed(gamespeed_fps);
}
