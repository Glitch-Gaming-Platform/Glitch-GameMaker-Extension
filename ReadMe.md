# Glitch GameMaker Extension v3.0.2

The official [Glitch](https://glitch.fun) extension for **GameMaker**. It adds Glitch launch validation, playtime heartbeat payouts, achievements, leaderboards, cloud saves, analytics, and a Steam-to-Glitch bridge.

This package is meant to be dropped into a GameMaker project and used with a small number of GML calls.

---

## What changed in v3.0.2

This build keeps the v3.0.1 startup fixes and adds clearer progression support for achievements and leaderboards.

- Achievement and leaderboard submit requests are now tracked automatically, even when you call `glitch_report_achievement()` or `glitch_submit_score()` from a game object instead of `obj_glitch_manager`.
- Progression submit responses are saved to `global.glitch_progression_response`.
- Leaderboard GET responses are saved to `global.glitch_leaderboard_response`.
- Achievement loading now supports the documented response shape where the achievement key is nested at `achievement.api_key`.
- The Async HTTP handler now supports both `http_status` and older/example-style `status` fields.
- The README now explains the exact achievement and leaderboard setup flow.

---

## Installation

1. Unzip this package.
2. Copy `extensions/GlitchAegis` into your GameMaker project's `extensions/` folder.
3. Copy `objects/obj_glitch_manager` into your GameMaker project's `objects/` folder.
4. Copy `rooms/rm_glitch_init` into your GameMaker project's `rooms/` folder.
5. Open GameMaker.
6. Open the **Room Manager**.
7. Drag `rm_glitch_init` to the **top** of the room order.
8. Make sure your real first game room is either:
   - the room immediately after `rm_glitch_init`, or
   - the room named in the `target_room` extension option.
9. Double-click the **GlitchAegis** extension and fill in the options below.

---

## Extension options

Open the **GlitchAegis** extension, click the cog/options area, and configure these values.

| Option | Required | What to enter |
|---|---:|---|
| `title_id` | Yes | Your Glitch Title ID from the dashboard. |
| `title_token` | Yes | Your private Title Token from the dashboard. |
| `target_room` | Recommended | The room to enter after Glitch startup, for example `rm_main_menu`. |
| `dev_test_install_id` | Local testing only | A test install ID for F5/local playtesting. Leave blank for production. |
| `enable_auto_heartbeat` | No | `True` to send automatic playtime heartbeat calls. |
| `enforce_validation` | No | `True` to block play if the license/session is invalid. Use `False` while testing. |
| `enable_achievements` | No | `True` to auto-load player achievements on startup. |
| `enable_leaderboards` | No | `True` to enable leaderboard helper functions. |
| `enable_cloud_saves` | No | `True` to enable cloud save helper functions. |
| `enable_steam_bridge` | No | `True` to use the Steam replacement helpers. |

For local testing, paste a valid `dev_test_install_id`. In production, Glitch passes `install_id` into the game launch URL and the extension reads it automatically.

---

## Required room setup

`rm_glitch_init` must be first.

The included `obj_glitch_manager` lives in `rm_glitch_init`. It initializes the extension, validates the install/session, starts heartbeat if enabled, loads achievements if enabled, and then moves to your target room.

You do **not** need to place `obj_glitch_manager` in every room.

---

## Quick implementation checklist

Use this order when adding Glitch to a GameMaker game:

1. Install the extension folders.
2. Put `rm_glitch_init` first in the Room Manager.
3. Set `title_id`, `title_token`, and `target_room` in the extension options.
4. For local testing, set `dev_test_install_id`.
5. Create achievement/stat keys and leaderboard keys in the Glitch dashboard.
6. Call `glitch_report_achievement()` when the player makes achievement progress.
7. Call `glitch_submit_score()` when the player earns a score.
8. Call `glitch_get_leaderboard()` when you want to draw a leaderboard screen.
9. Use the global response/cache variables listed below to display results.

---

## Achievements

### How achievements work

Glitch achievements unlock through the progression submit endpoint:

```json
{
  "idempotency_key": "unique_string",
  "payload": {
    "stats": {
      "boss_kills": 1
    }
  }
}
```

In GameMaker, you normally do not build this JSON yourself. Use:

```gml
glitch_report_achievement("boss_kills", 1);
```

### Important: achievement key vs stat key

The value you pass to `glitch_report_achievement(api_key, value)` is the **stat/progression key that the achievement tracks**.

For simple achievements, use the same key in the dashboard and in code:

```gml
// Dashboard key: tutorial_done
// Unlock threshold: 1
glitch_report_achievement("tutorial_done", 1);
```

For progress achievements, send the current progress value or increment value expected by your backend configuration:

```gml
// Dashboard/stat key: total_kills
// Unlock threshold: 100
glitch_report_achievement("total_kills", 50);
```

If your dashboard separates a public trophy key from the stat key it tracks, pass the **stat key**, not the display/trophy name.

### Simple unlock example

```gml
// Player finished the tutorial.
glitch_report_achievement("tutorial_done", 1);
```

### Progress achievement example

```gml
// Player now has 50 total kills.
glitch_report_achievement("total_kills", 50);
```

### Checking whether an achievement is unlocked

Achievements are loaded automatically on startup when `enable_achievements` is `True`.

```gml
if (glitch_is_achievement_unlocked("tutorial_done")) {
    // Show unlocked trophy UI.
}
```

### Checking progress

```gml
var _kills = glitch_get_achievement_progress("total_kills");
```

### Refreshing achievements manually

```gml
glitch_load_achievements();
```

The cache is updated when the load response returns.

### Showing unlock feedback

After `glitch_report_achievement()` succeeds, the raw progression response is stored here:

```gml
global.glitch_progression_response
```

The extension also updates `global.glitch_ach_cache` when the response includes newly unlocked achievements.

---

## Leaderboards

### How leaderboards work

Glitch leaderboards use the same progression submit endpoint, but scores go under `payload.scores`:

```json
{
  "idempotency_key": "unique_string",
  "payload": {
    "scores": {
      "global_high_score": 5000
    }
  }
}
```

In GameMaker, use:

```gml
glitch_submit_score("global_high_score", 5000);
```

### Dashboard setup

Create a leaderboard in the Glitch dashboard and copy its **Key**.

Examples:

| Leaderboard | Key | Sort order |
|---|---|---|
| Global High Score | `global_high_score` | Highest number wins / descending |
| Fastest Clear Time | `fastest_clear_time` | Lowest number wins / ascending |
| Most Kills | `total_kills` | Highest number wins / descending |

The key in your GML call must exactly match the dashboard key.

### Submitting a score

```gml
// Submit a literal score.
glitch_submit_score("global_high_score", 5000);

// Submit from a variable.
glitch_submit_score("global_high_score", global.player_score);
```

### Downloading a leaderboard

```gml
glitch_get_leaderboard("global_high_score");
```

When the request completes, the raw JSON is stored here:

```gml
global.glitch_leaderboard_response
```

You can parse it with `json_decode()` after the response arrives.

Example:

```gml
if (global.glitch_leaderboard_response != "") {
    var _data = json_decode(global.glitch_leaderboard_response);

    if (ds_exists(_data, ds_type_map) && ds_map_exists(_data, "data")) {
        var _entries = ds_map_find_value(_data, "data");

        if (ds_exists(_entries, ds_type_list)) {
            for (var i = 0; i < ds_list_size(_entries); i++) {
                var _entry = ds_list_find_value(_entries, i);
                if (ds_exists(_entry, ds_type_map)) {
                    var _rank = ds_map_find_value(_entry, "rank");
                    var _score = ds_map_find_value(_entry, "score");
                    show_debug_message("Rank " + string(_rank) + ": " + string(_score));
                }
            }
        }
    }

    ds_map_destroy(_data);
}
```

---

## Achievements + leaderboards in one event

If the player finishes a run and you want to submit both progress and score, call both helpers:

```gml
// Player ended a run.
glitch_report_achievement("runs_completed", global.runs_completed);
glitch_submit_score("global_high_score", global.player_score);
```

Both functions send valid Glitch progression requests. Each response is tracked by the extension.

---

## Cloud saves

### Save a JSON string

```gml
var _json = json_stringify({
    level: global.current_level,
    hp: obj_player.hp,
    coins: global.coins
});

glitch_cloud_save(1, _json);
```

### Save a ds_map

```gml
var _save = ds_map_create();
ds_map_add(_save, "level", global.current_level);
ds_map_add(_save, "hp", obj_player.hp);
ds_map_add(_save, "coins", global.coins);

glitch_cloud_save_map(1, _save);

ds_map_destroy(_save);
```

### Load saves

```gml
glitch_cloud_load();
```

After the response arrives, use:

```gml
var _data = glitch_cloud_parse_slot(global.glitch_cloud_response, 1);
```

Notes:

- Slots `0` through `99` are available.
- Use slot `0` for autosave and `1+` for manual saves.
- Cloud saves require a logged-in Glitch user. Guest players may receive `403`.

---

## Steam-to-Glitch bridge

Use this when your game already uses GameMaker's Steam functions and you want a simple migration path.

### Setup

1. In the Glitch dashboard, create achievements and leaderboards with keys matching your Steam API names.
2. Set `enable_steam_bridge` to `True`.
3. Replace your Steam calls with the bridge calls.

### Achievement example

```gml
// Before
steam_set_achievement("ACH_WIN_GAME");
steam_stats_store();

// After
glitch_steam_set_achievement("ACH_WIN_GAME");
glitch_steam_store_stats();
```

### Stat example

```gml
glitch_steam_set_stat_int("TotalKills", 150);
glitch_steam_store_stats();
```

### Leaderboard example

```gml
glitch_steam_upload_score("global_high_score", 5000);
glitch_steam_store_stats();
```

### Reading achievements

```gml
if (glitch_steam_get_achievement("ACH_WIN_GAME")) {
    // Show unlocked UI.
}
```

### Bridge function mapping

| Steam function | Glitch bridge function | Notes |
|---|---|---|
| `steam_set_achievement(name)` | `glitch_steam_set_achievement(name)` | Buffers until `glitch_steam_store_stats()`. |
| `steam_get_achievement(name)` | `glitch_steam_get_achievement(name)` | Reads the local achievement cache. |
| `steam_set_stat_int(name, value)` | `glitch_steam_set_stat_int(name, value)` | Buffers until store. |
| `steam_set_stat_float(name, value)` | `glitch_steam_set_stat_float(name, value)` | Buffers until store. |
| `steam_upload_score(board, score)` | `glitch_steam_upload_score(board, score)` | Buffers until store. |
| `steam_stats_store()` | `glitch_steam_store_stats()` | Flushes stats and scores to Glitch. |
| `steam_stats_request()` | `glitch_steam_request_stats()` | Refreshes achievement cache. |

---

## Function reference

### Core

| Function | Description |
|---|---|
| `glitch_init()` | Initializes the extension. Called automatically by `obj_glitch_manager`. |
| `glitch_validate_license()` | Validates the player's Glitch install/session. Called automatically. |
| `glitch_send_heartbeat()` | Sends playtime heartbeat. Called automatically when enabled. |

### Achievements

| Function | Description |
|---|---|
| `glitch_report_achievement(api_key, value)` | Sends stat/progression value for an achievement. |
| `glitch_load_achievements()` | Downloads the player's achievement list. |
| `glitch_is_achievement_unlocked(api_key)` | Returns `true` when cached status is `unlocked`. |
| `glitch_get_achievement_progress(api_key)` | Returns cached progress value, or `0`. |

### Leaderboards

| Function | Description |
|---|---|
| `glitch_submit_score(board_key, score)` | Submits a numeric score to a leaderboard. |
| `glitch_get_leaderboard(board_key)` | Downloads leaderboard entries into `global.glitch_leaderboard_response`. |

### Cloud saves

| Function | Description |
|---|---|
| `glitch_cloud_save(slot, json_string)` | Saves JSON text to a cloud slot. |
| `glitch_cloud_save_map(slot, ds_map)` | Saves a `ds_map` after encoding it to JSON. |
| `glitch_cloud_load()` | Downloads cloud saves into `global.glitch_cloud_response`. |
| `glitch_cloud_parse_slot(json, slot)` | Extracts one save slot from the cloud response. |

### Analytics

| Function | Description |
|---|---|
| `glitch_track_event(step_key, action_key)` | Sends an analytics event. |

---

## Global variables you may read

| Variable | Description |
|---|---|
| `global.glitch_install_id` | Current Glitch install/session ID. |
| `global.glitch_validated` | `true` after license validation succeeds. |
| `global.glitch_player_name` | Player display name when available. |
| `global.glitch_ach_loaded` | `true` once achievements have been loaded into cache. |
| `global.glitch_progression_response` | Raw JSON from the latest achievement/score submit response. |
| `global.glitch_leaderboard_response` | Raw JSON from the latest leaderboard GET response. |
| `global.glitch_cloud_response` | Raw JSON from the latest cloud save load response. |

---

## Troubleshooting

### The game says `No install_id found`

That is normal during local F5 testing unless you set `dev_test_install_id`. Paste a valid test install ID into the extension options.

### The game stays on the init room

Check these two things:

1. `rm_glitch_init` is first in the Room Manager.
2. `target_room` exactly matches your real room name, or your real room is immediately after `rm_glitch_init`.

### Achievement submit returns 404

The key you sent does not match a stat/progression key known by Glitch. Check the dashboard key and the spelling in your GML call.

### Achievement submit returns 401

Your `title_token` is missing or incorrect.

### Achievement submit returns 403

The player may be a guest or the install/session may not be authorized.

### Leaderboard response is empty

Make sure you called:

```gml
glitch_get_leaderboard("your_board_key");
```

Then wait for the Async HTTP response before reading:

```gml
global.glitch_leaderboard_response
```

### Scores do not show on the leaderboard

Check that:

- the leaderboard key exists in the dashboard,
- the score is a number,
- `title_id` and `title_token` are correct,
- the player has a valid `install_id`, and
- the board's write policy allows client submissions.

---

## Support

- Dashboard: [glitch.fun/games/admin](https://glitch.fun/games/admin)
- Documentation: [docs.glitch.fun](https://docs.glitch.fun)
- Discord: [discord.gg/RPYU9KgEmU](https://discord.gg/RPYU9KgEmU)
