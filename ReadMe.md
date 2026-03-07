# Glitch Aegis — GameMaker Extension v2.0

The **Glitch Aegis Extension** connects your GameMaker game to the [Glitch Gaming Platform](https://glitch.fun). It handles **playtime payouts**, **DRM license validation**, and **behavioral analytics** — all with a no-code setup that takes about 5 minutes.

---

## What Does This Extension Do?

When a player launches your game through Glitch.fun, they receive a unique **session ID** called an `install_id`. Glitch Aegis reads that ID and uses it to:

- **Record active playtime** — Every 60 seconds, the extension sends a "heartbeat" signal to Glitch. This is what earns you the **$0.10/hr developer payout**.
- **Validate the player's license** — Glitch checks whether this player has a valid Premium, Rental, or Subscription license for your game.
- **Track in-game events** — Optional analytics to see where players quit, die, or complete levels.

> **No code required** for the core features. Just configure three fields and drag one room to the top of your room list.

---

## Installation

### Step 1 — Download the Extension

Download this repository as a ZIP file and extract it. You'll see folders like `extensions/`, `objects/`, and `rooms/`.

### Step 2 — Copy Files Into Your Project

Copy these three folders into your GameMaker project directory (the folder containing your `.yyp` file):

```
extensions/GlitchAegis/
objects/obj_glitch_manager/
rooms/rm_glitch_init/
```

### Step 3 — Add Assets in GameMaker

Open GameMaker. In the **Asset Browser** on the right side:

1. Right-click **Extensions** → **Add Existing** → navigate to `extensions/GlitchAegis/GlitchAegis.yy`
2. Right-click **Objects** → **Add Existing** → navigate to `objects/obj_glitch_manager/obj_glitch_manager.yy`
3. Right-click **Rooms** → **Add Existing** → navigate to `rooms/rm_glitch_init/rm_glitch_init.yy`

### Step 4 — Move `rm_glitch_init` to the Top

Open the **Room Manager** (in the menu: **Tools → Room Manager**, or press the room order button). Drag `rm_glitch_init` all the way to the **top of the list**. This ensures it loads first, before any of your game rooms.

---

## Configuration (Required)

You must enter your Glitch credentials before the extension will work.

1. In the Asset Browser, click on **GlitchAegis** under Extensions.
2. In the Extension Properties panel, click the **Options** tab (or gear icon).
3. Fill in the following fields:

| Option | Where to Find It | Example |
|--------|-----------------|---------|
| `title_id` | Glitch Dashboard → your game → URL | `550e8400-e29b-41d4-a716-446655440000` |
| `title_token` | Glitch Dashboard → Technical Integration tab | `eyJhbGci...` |
| `target_room` | The name of your first game room | `rm_main_menu` |

> 💡 **Tip:** The `target_room` is the room your game normally starts in — your main menu, splash screen, etc. After Aegis initializes, it will automatically navigate there.

---

## All Extension Options

Here is the full list of options, what they do, and when to change them:

### `title_id` *(String, required)*
Your game's unique ID on the Glitch platform. This is a UUID that looks like `550e8400-e29b-41d4-...`. Find it in your Glitch Developer Dashboard.

### `title_token` *(String, required)*
A secret token that proves you are the developer of this title. Find it in the **Technical Integration** tab of your game's dashboard page. Keep this private — do not share it publicly.

### `target_room` *(String, default: `rm_main_menu`)*
The name of the room to navigate to after initialization is complete. This should be your game's main menu or first real room. Must match the exact name of the room in your Asset Browser.

### `enable_auto_heartbeat` *(Boolean, default: ON)*
When **ON**, the extension automatically sends a heartbeat signal to Glitch every 60 seconds in the background. This is what generates your **$0.10/hr payout** — so leave it ON unless you have a specific reason to disable it.

When **OFF**, you are responsible for calling `glitch_send_heartbeat()` yourself in your game code.

### `enforce_validation` *(Boolean, default: OFF)*
When **OFF** *(recommended for most games)*: The extension still validates the license, but if it fails, the game continues anyway. This is useful for games that can be played both on Glitch and elsewhere.

When **ON**: If the license check fails (or the game is launched without a Glitch session), the extension shows a **blocking error screen** and prevents the player from continuing. Use this for DRM-protected titles that should only run through Glitch.

### `dev_test_install_id` *(String, default: empty)*
For **local development only**. When you test your game inside GameMaker (by pressing the Play button), there is no Glitch session — so no `install_id` is available. Fill this field with a real `install_id` from a test session to simulate a Glitch launch.

**⚠️ Important:** Clear this field before you release your game. If you leave a test ID in this field in your published build, all players will appear to be the same test user.

---

## How It All Works Together

Here is what happens when a player plays your game through Glitch:

```
Player clicks "Play" on Glitch.fun
    ↓
Browser opens your game URL with ?install_id=XXXX in the address bar
    ↓
rm_glitch_init loads first (because you put it at the top)
    ↓
obj_glitch_manager runs glitch_init()
    → Reads your title_id, title_token from Extension Options
    → Reads install_id from the URL
    ↓
Sends a validation request to Glitch API
    → 200 OK + valid=true → moves to your target_room ✅
    → 403 Forbidden → shows error (if EnforceValidation ON) or continues anyway
    ↓
Every 60 seconds: sends heartbeat → earns $0.10/hr payout 💰
```

---

## Optional: Tracking In-Game Events

You can send behavioral analytics events to Glitch to see where players drop off. Call `glitch_track_event()` anywhere in your GML:

```gml
// When the player starts a level
glitch_track_event("level_1", "started");

// When the player dies
glitch_track_event("level_1", "died");

// When the player completes a level
glitch_track_event("level_1", "completed");

// When the player reaches the final boss
glitch_track_event("boss_fight", "started");
```

The first argument is the **step** (a screen or stage name), and the second is the **action**. You can use any strings you like — they'll appear in your Glitch Analytics dashboard.

---

## Optional: Manual Heartbeat Control

If you turned `enable_auto_heartbeat` **OFF**, you must call this yourself:

```gml
// In an alarm or step event — fire this every 60 seconds
glitch_send_heartbeat();
```

---

## Local Testing / Developer Mode

To test locally without a real Glitch session:

1. Log into Glitch.fun and start a session for your game.
2. Copy the `install_id` from the URL (it looks like a UUID after `?install_id=`).
3. Paste it into the `dev_test_install_id` Extension Option.
4. Press Play in GameMaker — the extension will use that ID instead of reading the URL.

Remember to **clear this field before publishing**.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Game stays on the init room forever | Check that `target_room` matches the exact room name in your Asset Browser (case-sensitive). |
| Error screen appears saying "No valid session found" | Make sure you launched the game from Glitch.fun, or fill in `dev_test_install_id` for local testing. |
| "401 Unauthorized" error | Your `title_token` is wrong or expired. Regenerate it in the Technical Integration tab. |
| "422" error | Your `title_id` is malformed. Make sure it's a valid UUID from your dashboard. |
| Heartbeat isn't sending | Verify `enable_auto_heartbeat` is ON and `title_id` / `title_token` are filled in. |
| Error overlay can't be dismissed | If `enforce_validation` is ON, the overlay is intentionally permanent. Turn it OFF if you don't want to enforce DRM. |

---

## GML Function Reference

| Function | Description |
|----------|-------------|
| `glitch_init()` | Initializes the extension. Called automatically — you don't need to call this. |
| `glitch_send_heartbeat()` | Sends a playtime heartbeat. Returns the HTTP request ID. |
| `glitch_validate_license()` | Validates the player's license. Returns the HTTP request ID. |
| `glitch_track_event(step, action)` | Sends a behavioral analytics event. |
| `glitch_show_error(message)` | Shows the Glitch error overlay with a custom message. |
| `glitch_dismiss_error()` | Dismisses the error overlay (only works if `enforce_validation` is OFF). |

---

## Support

- **API Documentation:** [api.glitch.fun/api/documentation](https://api.glitch.fun/api/documentation)
- **Developer Discord:** [discord.gg/RPYU9KgEmU](https://discord.gg/RPYU9KgEmU)
- **Platform:** [glitch.fun](https://glitch.fun)

---

*Glitch Aegis v2.0 — Developed for the Glitch Gaming Platform. © 2026 Glitch Studios.*
