// obj_glitch_manager — Alarm 0 Event
// ────────────────────────────────────
// Fires every 60 seconds to send a playtime heartbeat.
// Only runs if EnableAutoHeartbeat is ON.
// To disable, set the option to OFF in Extension Options.

if (global.glitch_auto_heartbeat) {
    heartbeat_req = glitch_send_heartbeat();
    alarm[0] = 60 * room_speed; // Schedule the next heartbeat
}
