# Glitch GameMaker Extension v3.0.0

The official [Glitch](https://glitch.fun) extension for **GameMaker**. Zero-code heartbeat payouts and DRM, with simple one-line GML calls for achievements, leaderboards, cloud saves, and analytics. Includes a Steam-to-Glitch bridge for easy migration.

---

## Installation

1. Download or clone this repository.
2. Copy the `extensions/GlitchAegis` folder into your project's `extensions/` directory.
3. Copy the `objects/obj_glitch_manager` folder into your project's `objects/` directory.
4. Copy the `rooms/rm_glitch_init` folder into your project's `rooms/` directory.
5. In GameMaker, open the **Room Manager** and drag `rm_glitch_init` to the **very top** of the room order.
6. Double-click the **GlitchAegis** extension and configure your settings (see below).

---

## Quick Start (3 Steps)

### Step 1: Get Your Credentials

1. Go to [glitch.fun](https://glitch.fun) → **My Games** → select your game.
2. Open the **Technical Integration** page.
3. Copy your **Title ID**, **Title Token**, and **Developer Test Install ID**.

### Step 2: Configure the Extension

Double-click the **GlitchAegis** extension in GameMaker. Click the **Cog Icon** and fill in:

| Option | What to Enter |
|--------|--------------|
| **title_id** | Your UUID from the dashboard |
| **title_token** | Your private API token |
| **target_room** | The room to go to after init (e.g. `rm_main_menu`) |
| **dev_test_install_id** | Your dev test ID (for F5 playtesting) |

Toggle features ON/OFF:

| Option | Default | What It Does |
|--------|---------|-------------|
| **enable_auto_heartbeat** | ✅ ON | Earns $0.10/hr payouts automatically |
| **enforce_validation** | ❌ OFF | Blocks game if license is invalid |
| **enable_achievements** | ✅ ON | Auto-loads achievement data on startup |
| **enable_leaderboards** | ✅ ON | Enables score submission functions |
| **enable_cloud_saves** | ✅ ON | Enables cloud save/load functions |
| **enable_steam_bridge** | ❌ OFF | Enables Steam-to-Glitch replacement functions |

### Step 3: Set Room Order

Open the **Room Manager** and drag `rm_glitch_init` to the top. The game will validate the license and start payouts before moving to your game.

**That's it!** Heartbeat and DRM work with zero code.

---

## Achievements

### Dashboard Setup

Define achievements on the Glitch dashboard with an **API Key** (e.g. `boss_killed`) and an **Unlock Threshold** (e.g. `1`).

### Usage (One Line)

```gml
// Player beat the first boss:
glitch_report_achievement("boss_killed", 1);

// Player collected their 50th coin (cumulative):
glitch_report_achievement("coin_collector", 50);
```

### Checking Status

```gml
// In a conditional:
if (glitch_is_achievement_unlocked("boss_killed")) {
    // Show golden trophy sprite
}

// Get progress value:
var _progress = glitch_get_achievement_progress("coin_collector");
```

---

## Leaderboards

### Dashboard Setup

Define leaderboards on the dashboard with an **API Key** and **Sort Order**.

### Submitting Scores

```gml
// Submit a score directly:
glitch_submit_score("high_score", 5000);

// Submit from a variable:
glitch_submit_score("high_score", global.player_score);
```

### Downloading Scores

```gml
// Request the leaderboard data:
leaderboard_req = glitch_get_leaderboard("high_score");

// In the Async HTTP Event, check:
// global.glitch_leaderboard_response contains the JSON
```

---

## Cloud Saves

### Saving Data

```gml
// Option 1: Save a JSON string
var _json = json_stringify({
    level: global.current_level,
    hp: obj_player.hp,
    coins: global.coins,
    inventory: global.inventory
});
glitch_cloud_save(1, _json);

// Option 2: Save a ds_map directly
var _save = ds_map_create();
ds_map_add(_save, "level", global.current_level);
ds_map_add(_save, "hp", obj_player.hp);
ds_map_add(_save, "coins", global.coins);
glitch_cloud_save_map(1, _save);
ds_map_destroy(_save);
```

### Loading Data

```gml
// Step 1: Request the download
cloud_load_req = glitch_cloud_load();

// Step 2: In the Async HTTP Event (or after it completes),
//         parse the specific slot you want:
var _data = glitch_cloud_parse_slot(global.glitch_cloud_response, 1);
if (_data != "") {
    var _save = json_decode(_data);
    // Restore your game state from the map
    global.current_level = ds_map_find_value(_save, "level");
    obj_player.hp = ds_map_find_value(_save, "hp");
    ds_map_destroy(_save);
}
```

### Important Notes

- **Slots**: 0-99 available. Use 0 for auto-save, 1+ for manual.
- **Version tracking**: The extension tracks versions automatically to prevent conflicts.
- **Guest players**: Cloud saves require a logged-in Glitch user (403 for guests).

---

## Steam-to-Glitch Migration

If your game already uses **GameMaker's Steam API** functions, the Steam Bridge lets you redirect those calls to Glitch.

### Prerequisites

1. On the Glitch dashboard, create achievements and leaderboards with **the same API names** you used on Steam.
2. Set **enable_steam_bridge** to **True** in the extension options.

### Replace Your Steam Calls

```gml
// ─── BEFORE (Steam) ─────────────────────────
steam_set_achievement("ACH_WIN_GAME");
steam_set_stat_int("TotalKills", 150);
steam_stats_store();

// ─── AFTER (Glitch Bridge) ──────────────────
glitch_steam_set_achievement("ACH_WIN_GAME");
glitch_steam_set_stat_int("TotalKills", 150);
glitch_steam_store_stats();
```

### Leaderboards

```gml
// ─── BEFORE (Steam) ─────────────────────────
steam_upload_score("high_score", 5000);

// ─── AFTER (Glitch Bridge) ──────────────────
glitch_steam_upload_score("high_score", 5000);
glitch_steam_store_stats();  // Flushes to Glitch
```

### Reading Achievements

```gml
if (glitch_steam_get_achievement("ACH_WIN_GAME")) {
    // Show trophy
}
```

### Using a Macro Switch

For maintaining both Steam and Glitch builds from the same project, define a macro:

```gml
// In a script or macro definition:
#macro USE_GLITCH true

// Then in your game code:
if (USE_GLITCH) {
    glitch_steam_set_achievement("ACH_WIN_GAME");
    glitch_steam_store_stats();
} else {
    steam_set_achievement("ACH_WIN_GAME");
    steam_stats_store();
}
```

### What the Bridge Handles

| Steam Function | Bridge Equivalent | Notes |
|---|---|---|
| `steam_set_achievement(name)` | `glitch_steam_set_achievement(name)` | Buffered until store_stats |
| `steam_get_achievement(name)` | `glitch_steam_get_achievement(name)` | Uses local cache |
| `steam_set_stat_int(name, val)` | `glitch_steam_set_stat_int(name, val)` | Buffered |
| `steam_set_stat_float(name, val)` | `glitch_steam_set_stat_float(name, val)` | Buffered |
| `steam_upload_score(board, score)` | `glitch_steam_upload_score(board, score)` | Buffered |
| `steam_stats_store()` | `glitch_steam_store_stats()` | Flushes all to Glitch |
| `steam_stats_request()` | `glitch_steam_request_stats()` | Refreshes cache |

---

## Function Reference

### Core (Automatic)

| Function | Description |
|----------|------------|
| `glitch_init()` | Initializes the SDK. Called automatically by obj_glitch_manager. |
| `glitch_send_heartbeat()` | Sends a playtime heartbeat. Auto-called every 60s. |
| `glitch_validate_license()` | Validates the player's license. Auto-called on startup. |

### Achievements

| Function | Description |
|----------|------------|
| `glitch_report_achievement(api_key, value)` | Reports progress. Unlocks if threshold is met. |
| `glitch_is_achievement_unlocked(api_key)` | Returns `true` if unlocked (local cache). |
| `glitch_get_achievement_progress(api_key)` | Returns progress value (local cache). |
| `glitch_load_achievements()` | Force-refresh from server. |

### Leaderboards

| Function | Description |
|----------|------------|
| `glitch_submit_score(board_key, score)` | Submits a score. |
| `glitch_get_leaderboard(board_key)` | Downloads entries. Result in `global.glitch_leaderboard_response`. |

### Cloud Saves

| Function | Description |
|----------|------------|
| `glitch_cloud_save(slot, json_string)` | Saves a JSON string to a cloud slot. |
| `glitch_cloud_save_map(slot, ds_map)` | Saves a ds_map (auto-encodes to JSON). |
| `glitch_cloud_load()` | Downloads all slots. Result in `global.glitch_cloud_response`. |
| `glitch_cloud_parse_slot(json, slot)` | Extracts decoded data from a specific slot. |

### Analytics

| Function | Description |
|----------|------------|
| `glitch_track_event(step_key, action_key)` | Tracks a player behavior event. |

### Global Variables

| Variable | Description |
|----------|------------|
| `global.glitch_install_id` | The current session UUID |
| `global.glitch_validated` | `true` if DRM passed |
| `global.glitch_player_name` | Player's Glitch display name |
| `global.glitch_ach_loaded` | `true` once achievements are cached |
| `global.glitch_cloud_response` | Raw JSON from last cloud load |
| `global.glitch_leaderboard_response` | Raw JSON from last leaderboard download |

---

## Troubleshooting

### "No install_id found" in output

Normal when running locally. Paste your **dev_test_install_id** in the extension options.

### Achievements return 403

Player is a guest (not logged into Glitch). Show a "Log in to track progress" message.

### Cloud save returns 409

Version conflict — player saved on two devices. The console logs the conflict.

### Target room not found

Make sure the **target_room** option matches the exact room name in your project (e.g. `rm_main_menu`).

---

## Support

- **Dashboard**: [glitch.fun/games/admin](https://glitch.fun/games/admin)
- **Documentation**: [docs.glitch.fun](https://docs.glitch.fun)
- **Discord**: [discord.gg/RPYU9KgEmU](https://discord.gg/RPYU9KgEmU)
