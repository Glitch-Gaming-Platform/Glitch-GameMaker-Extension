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
  "extensionVersion": "3.0.2",
  "files": [
    {
      "filename": "glitch_aegis.gml",
      "kind": 2,
      "functions": [
        {
          "name": "_glitch_option_string_or_empty",
          "externalName": "_glitch_option_string_or_empty",
          "kind": 2,
          "help": "Internal: read extension option as safe string.",
          "returnType": 1,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_option_string",
          "externalName": "_glitch_option_string",
          "kind": 2,
          "help": "Internal: read extension option as string with fallback.",
          "returnType": 1,
          "argCount": 2,
          "args": [
            1,
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_option_bool",
          "externalName": "_glitch_option_bool",
          "kind": 2,
          "help": "Internal: read extension option as boolean with fallback.",
          "returnType": 2,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_clean_runtime_string",
          "externalName": "_glitch_clean_runtime_string",
          "kind": 2,
          "help": "Internal: normalize runtime value to string.",
          "returnType": 1,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_ensure_state",
          "externalName": "_glitch_ensure_state",
          "kind": 2,
          "help": "Internal: ensure Glitch globals and maps exist.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_headers",
          "externalName": "_glitch_headers",
          "kind": 2,
          "help": "Internal: create Glitch API HTTP headers map.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_continue_to_target_room",
          "externalName": "_glitch_continue_to_target_room",
          "kind": 2,
          "help": "Internal: continue from init room to configured target room.",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_uuid",
          "externalName": "_glitch_uuid",
          "kind": 2,
          "help": "Internal: create idempotency UUID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "_glitch_parse_achievements_response",
          "externalName": "_glitch_parse_achievements_response",
          "kind": 2,
          "help": "Internal: parse achievement response JSON.",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_init",
          "externalName": "glitch_init",
          "kind": 2,
          "help": "glitch_init() \u2014 Initializes the extension. Called automatically.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_send_heartbeat",
          "externalName": "glitch_send_heartbeat",
          "kind": 2,
          "help": "glitch_send_heartbeat() \u2014 Sends a playtime heartbeat. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_validate_license",
          "externalName": "glitch_validate_license",
          "kind": 2,
          "help": "glitch_validate_license() \u2014 Validates the player's license. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_load_achievements",
          "externalName": "glitch_load_achievements",
          "kind": 2,
          "help": "glitch_load_achievements() \u2014 Downloads the player's achievement list. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_report_achievement",
          "externalName": "glitch_report_achievement",
          "kind": 2,
          "help": "glitch_report_achievement(api_key, value) \u2014 Reports progress toward an achievement.",
          "returnType": 1,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_is_achievement_unlocked",
          "externalName": "glitch_is_achievement_unlocked",
          "kind": 2,
          "help": "glitch_is_achievement_unlocked(api_key) \u2014 Returns true if the achievement is unlocked (local cache).",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_get_achievement_progress",
          "externalName": "glitch_get_achievement_progress",
          "kind": 2,
          "help": "glitch_get_achievement_progress(api_key) \u2014 Returns the progress value (local cache).",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_submit_score",
          "externalName": "glitch_submit_score",
          "kind": 2,
          "help": "glitch_submit_score(board_key, score) \u2014 Submits a score to a leaderboard.",
          "returnType": 1,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_get_leaderboard",
          "externalName": "glitch_get_leaderboard",
          "kind": 2,
          "help": "glitch_get_leaderboard(board_key) \u2014 Downloads leaderboard entries. Returns HTTP request ID.",
          "returnType": 1,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_save",
          "externalName": "glitch_cloud_save",
          "kind": 2,
          "help": "glitch_cloud_save(slot, json_data) \u2014 Saves a JSON string to a cloud slot (0-99).",
          "returnType": 1,
          "argCount": 2,
          "args": [
            2,
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_save_map",
          "externalName": "glitch_cloud_save_map",
          "kind": 2,
          "help": "glitch_cloud_save_map(slot, ds_map) \u2014 Saves a ds_map to a cloud slot (auto-encodes to JSON).",
          "returnType": 1,
          "argCount": 2,
          "args": [
            2,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_load",
          "externalName": "glitch_cloud_load",
          "kind": 2,
          "help": "glitch_cloud_load() \u2014 Downloads all cloud save slots. Check global.glitch_cloud_response.",
          "returnType": 1,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_cloud_parse_slot",
          "externalName": "glitch_cloud_parse_slot",
          "kind": 2,
          "help": "glitch_cloud_parse_slot(response_json, slot_index) \u2014 Extracts decoded data from a cloud slot.",
          "returnType": 1,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_track_event",
          "externalName": "glitch_track_event",
          "kind": 2,
          "help": "glitch_track_event(step_key, action_key) \u2014 Tracks a behavioral analytics event.",
          "returnType": 1,
          "argCount": 2,
          "args": [
            1,
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_achievement",
          "externalName": "glitch_steam_set_achievement",
          "kind": 2,
          "help": "glitch_steam_set_achievement(api_name) \u2014 Steam Bridge: buffers an achievement unlock.",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_stat_int",
          "externalName": "glitch_steam_set_stat_int",
          "kind": 2,
          "help": "glitch_steam_set_stat_int(stat_name, value) \u2014 Steam Bridge: buffers an integer stat.",
          "returnType": 2,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_set_stat_float",
          "externalName": "glitch_steam_set_stat_float",
          "kind": 2,
          "help": "glitch_steam_set_stat_float(stat_name, value) \u2014 Steam Bridge: buffers a float stat.",
          "returnType": 2,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_upload_score",
          "externalName": "glitch_steam_upload_score",
          "kind": 2,
          "help": "glitch_steam_upload_score(board_key, score) \u2014 Steam Bridge: buffers a leaderboard score.",
          "returnType": 2,
          "argCount": 2,
          "args": [
            1,
            2
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_get_achievement",
          "externalName": "glitch_steam_get_achievement",
          "kind": 2,
          "help": "glitch_steam_get_achievement(api_name) \u2014 Steam Bridge: checks if achievement is unlocked.",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_store_stats",
          "externalName": "glitch_steam_store_stats",
          "kind": 2,
          "help": "glitch_steam_store_stats() \u2014 Steam Bridge: flushes all buffered stats/scores to Glitch.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_steam_request_stats",
          "externalName": "glitch_steam_request_stats",
          "kind": 2,
          "help": "glitch_steam_request_stats() \u2014 Steam Bridge: refreshes achievement cache from Glitch.",
          "returnType": 2,
          "argCount": 0,
          "args": [],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_show_error",
          "externalName": "glitch_show_error",
          "kind": 2,
          "help": "glitch_show_error(message) \u2014 Shows the error overlay.",
          "returnType": 2,
          "argCount": 1,
          "args": [
            1
          ],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_dismiss_error",
          "externalName": "glitch_dismiss_error",
          "kind": 2,
          "help": "glitch_dismiss_error() \u2014 Dismisses the error overlay (if enforce_validation is OFF).",
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
          "args": [
            1
          ],
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