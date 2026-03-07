// obj_glitch_manager — Create Event
// ─────────────────────────────────
// This runs once when the game starts (in rm_glitch_init).
// It initializes the Aegis system, validates the license,
// and starts the auto-heartbeat timer if enabled.

// 1. Initialize — reads options, detects install_id
glitch_init();

// 2. Track request IDs for async response handling
validation_req = -1;
heartbeat_req  = -1;

// 3. Validate the player's license
validation_req = glitch_validate_license();

// 4. Start auto-heartbeat (if enabled in Extension Options)
if (global.glitch_auto_heartbeat) {
    heartbeat_req = glitch_send_heartbeat();
    alarm[0] = 60 * room_speed; // Repeats every 60 seconds
}
