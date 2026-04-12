{
  "optionsFile": "options.json",
  "options": [
    {
      "name": "title_id",
      "type": 2,
      "value": "",
      "description": "Your Glitch Title ID (UUID). Found on the Glitch Developer Dashboard.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "title_token",
      "type": 2,
      "value": "",
      "description": "Your private Title Token. Generated on the dashboard Technical page.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "target_room",
      "type": 2,
      "value": "rm_main_menu",
      "description": "Room to go to after successful initialization (e.g. rm_main_menu).",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_auto_heartbeat",
      "type": 3,
      "value": "True",
      "description": "When ON, automatically sends a playtime heartbeat every 60s to earn $0.10/hr payouts.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enforce_validation",
      "type": 3,
      "value": "False",
      "description": "When ON, blocks the game with an error screen if the license is invalid.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_achievements",
      "type": 3,
      "value": "True",
      "description": "When ON, auto-loads achievement data on startup. Use glitch_report_achievement() to unlock.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_leaderboards",
      "type": 3,
      "value": "True",
      "description": "When ON, enables glitch_submit_score() and glitch_get_leaderboard().",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_cloud_saves",
      "type": 3,
      "value": "True",
      "description": "When ON, enables glitch_cloud_save() and glitch_cloud_load().",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_steam_bridge",
      "type": 3,
      "value": "False",
      "description": "When ON, use glitch_steam_* functions as drop-in replacements for Steam API calls.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "dev_test_install_id",
      "type": 2,
      "value": "",
      "description": "Dev testing only. Paste a valid install_id to bypass URL detection during local testing.",
      "resourceType": "GMExtensionOption"
    }
  ],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "3.0.0",
  "files": [
    {
      "filename": "glitch_aegis.gml",
      "kind": 2,
      "functions": [
        {
          "name": "glitch_init",
          "externalName": "glitch_init",
          "kind": 2,
          "help": "glitch_init() — Initializes the extension. Called automatically.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_send_heartbeat",
          "externalName": "glitch_send_heartbeat",
          "kind": 2,
          "help": "glitch_send_heartbeat() — Sends a playtime heartbeat. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_validate_license",
          "externalName": "glitch_validate_license",
          "kind": 2,
          "help": "glitch_validate_license() — Validates the player's license. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_load_achievements",
          "externalName": "glitch_load_achievements",
          "kind": 2,
          "help": "glitch_load_achievements() — Downloads the player's achievement list. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_report_achievement",
          "externalName": "glitch_report_achievement",
          "kind": 2,
          "help": "glitch_report_achievement(api_key, value) — Reports progress toward an achievement.",
          "returnType": 1,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_is_achievement_unlocked",
          "externalName": "glitch_is_achievement_unlocked",
          "kind": 2,
          "help": "glitch_is_achievement_unlocked(api_key) — Returns true if the achievement is unlocked (local cache).",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_get_achievement_progress",
          "externalName": "glitch_get_achievement_progress",
          "kind": 2,
          "help": "glitch_get_achievement_progress(api_key) — Returns the progress value (local cache).",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_submit_score",
          "externalName": "glitch_submit_score",
          "kind": 2,
          "help": "glitch_submit_score(board_key, score) — Submits a score to a leaderboard.",
          "returnType": 1,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_get_leaderboard",
          "externalName": "glitch_get_leaderboard",
          "kind": 2,
          "help": "glitch_get_leaderboard(board_key) — Downloads leaderboard entries. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_save",
          "externalName": "glitch_cloud_save",
          "kind": 2,
          "help": "glitch_cloud_save(slot, json_data) — Saves a JSON string to a cloud slot (0-99).",
          "returnType": 1,
          "argCount": 2,
          "args": [2, 1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_save_map",
          "externalName": "glitch_cloud_save_map",
          "kind": 2,
          "help": "glitch_cloud_save_map(slot, ds_map) — Saves a ds_map to a cloud slot (auto-encodes to JSON).",
          "returnType": 1,
          "argCount": 2,
          "args": [2, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_load",
          "externalName": "glitch_cloud_load",
          "kind": 2,
          "help": "glitch_cloud_load() — Downloads all cloud save slots. Check global.glitch_cloud_response.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_parse_slot",
          "externalName": "glitch_cloud_parse_slot",
          "kind": 2,
          "help": "glitch_cloud_parse_slot(response_json, slot_index) — Extracts decoded data from a cloud slot.",
          "returnType": 1,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_track_event",
          "externalName": "glitch_track_event",
          "kind": 2,
          "help": "glitch_track_event(step_key, action_key) — Tracks a behavioral analytics event.",
          "returnType": 1,
          "argCount": 2,
          "args": [1, 1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_achievement",
          "externalName": "glitch_steam_set_achievement",
          "kind": 2,
          "help": "glitch_steam_set_achievement(api_name) — Steam Bridge: buffers an achievement unlock.",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_stat_int",
          "externalName": "glitch_steam_set_stat_int",
          "kind": 2,
          "help": "glitch_steam_set_stat_int(stat_name, value) — Steam Bridge: buffers an integer stat.",
          "returnType": 2,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_stat_float",
          "externalName": "glitch_steam_set_stat_float",
          "kind": 2,
          "help": "glitch_steam_set_stat_float(stat_name, value) — Steam Bridge: buffers a float stat.",
          "returnType": 2,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_upload_score",
          "externalName": "glitch_steam_upload_score",
          "kind": 2,
          "help": "glitch_steam_upload_score(board_key, score) — Steam Bridge: buffers a leaderboard score.",
          "returnType": 2,
          "argCount": 2,
          "args": [1, 2],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_get_achievement",
          "externalName": "glitch_steam_get_achievement",
          "kind": 2,
          "help": "glitch_steam_get_achievement(api_name) — Steam Bridge: checks if achievement is unlocked.",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_store_stats",
          "externalName": "glitch_steam_store_stats",
          "kind": 2,
          "help": "glitch_steam_store_stats() — Steam Bridge: flushes all buffered stats/scores to Glitch.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_request_stats",
          "externalName": "glitch_steam_request_stats",
          "kind": 2,
          "help": "glitch_steam_request_stats() — Steam Bridge: refreshes achievement cache from Glitch.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_show_error",
          "externalName": "glitch_show_error",
          "kind": 2,
          "help": "glitch_show_error(message) — Shows the error overlay.",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_dismiss_error",
          "externalName": "glitch_dismiss_error",
          "kind": 2,
          "help": "glitch_dismiss_error() — Dismisses the error overlay (if enforce_validation is OFF).",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        }
      ],
      "resourceType": "GMExtensionFile"
    },
    {
      "filename": "glitch_bridge.js",
      "kind": 5,
      "functions": [
        {
          "name": "glitch_js_get_url_param",
          "externalName": "glitch_js_get_url_param",
          "kind": 5,
          "help": "",
          "returnType": 1,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_js_get_user_agent",
          "externalName": "glitch_js_get_user_agent",
          "kind": 5,
          "help": "",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_js_get_screen_info",
          "externalName": "glitch_js_get_screen_info",
          "kind": 5,
          "help": "",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        }
      ],
      "resourceType": "GMExtensionFile"
    }
  ],
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy"
  },
  "resourceVersion": "1.2",
  "name": "GlitchAegis",
  "resourceType": "GMExtension"
}
