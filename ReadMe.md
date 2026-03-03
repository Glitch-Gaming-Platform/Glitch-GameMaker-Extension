# Glitch Aegis GameMaker Extension

The **Glitch Aegis Extension** is a no-code integration for GameMaker (2.3+) that connects your game to the Glitch distribution platform. It enables **DRM (Digital Rights Management)**, **Playtime Payouts**, and **Behavioral Analytics** with minimal setup.

---

## 🚀 Features

*   **Automated Payouts:** Automatically sends heartbeats every 60 seconds to record active playtime, triggering the **$0.10/hr developer payout**.
*   **Aegis DRM:** Validates the player's license (Premium, Rental, or Subscription) on launch.
*   **Cross-Platform Attribution:** Links game installs to marketing campaigns, influencers, and advertisements.
*   **Behavioral Funnels:** Track in-game events (e.g., tutorial completion, level reached) to analyze player drop-off.
*   **No-Code Ready:** Includes a persistent manager object and initialization room—just drop it in and go.

---

## 📦 Installation

1.  **Download** this repository as a ZIP file.
2.  **Extract** the contents into your GameMaker project folder.
3.  In GameMaker, right-click **Extensions** in the Asset Browser and select **Add Existing**.
4.  Navigate to `extensions/GlitchAegis/` and select `GlitchAegis.yy`.
5.  Repeat the process for the **Object** (`objects/obj_glitch_manager/obj_glitch_manager.yy`) and the **Room** (`rooms/rm_glitch_init/rm_glitch_init.yy`).

---

## ⚙️ Configuration

Before running your game, you must link it to your Glitch Dashboard:

1.  Open the **GlitchAegis** extension in your Asset Browser.
2.  Click the **Options** (cog icon) at the bottom of the Extension Properties.
3.  Enter your credentials:
    *   `title_id`: Found in your Glitch Developer Dashboard.
    *   `title_token`: Generated in the **Technical Integration** tab of your title.

---

## 🛠️ No-Code Setup

To enable all features without writing any GML:

1.  Open the **Room Manager** (Room Order).
2.  Drag `rm_glitch_init` to the very top of the list so it is the **first room** that loads.
3.  In your game's main menu or starting logic, use `room_goto()` to move from the init room to your actual game.
4.  The `obj_glitch_manager` is **persistent**; it will stay active in the background, handling security and payouts while the player enjoys your game.

---

## 💻 Advanced GML Usage

If you want to customize the integration or track specific player actions, use the following functions:

### `glitch_track_event(step_key, action_key)`
Tracks a behavioral event for funnel analysis.

| Argument | Type | Description |
| :--- | :--- | :--- |
| `step_key` | String | The stage or screen (e.g., "level_1", "boss_fight"). |
| `action_key` | String | The action taken (e.g., "started", "died", "completed"). |

**Example:**
```gml
if (player_reached_end) {
    glitch_track_event("level_1", "completed");
}
```

### `glitch_send_heartbeat()`
Manually triggers a playtime recording. Note: The manager object does this automatically every 60 seconds.

### `glitch_validate_license()`
Triggers a security check. Returns an HTTP request ID. Handle the response in the **HTTP Async Event**.

---

## ⚠️ Technical Notes

*   **Idle Detection:** Payouts are only generated for "Active" time. If the Glitch platform detects no input (mouse/keyboard) for 5 minutes, heartbeats are flagged as idle and will not generate revenue.
*   **Web Exports:** For HTML5 builds, ensure `glitch_bridge.js` is included in the extension files to allow the game to read the `install_id` from the browser URL.
*   **Security:** If `glitch_validate_license` returns a `403 Forbidden` status code, the extension is configured to call `game_end()` by default to prevent unauthorized access.

---

## 🆘 Support

*   **Documentation:** [Glitch API Docs](https://api.glitch.fun/api/documentation)
*   **Discord:** [Join our Developer Community](https://discord.gg/RPYU9KgEmU)
*   **Website:** [glitch.fun](https://www.glitch.fun)

---
*Developed for the Glitch Gaming Platform. © 2026 Glitch Studios.*
