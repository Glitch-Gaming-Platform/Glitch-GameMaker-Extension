{
  "optionsFile": "options.json",
  "options": [
    {
      "name": "title_id",
      "type": 2,
      "value": "",
      "description": "Your Glitch Title ID (UUID). Found in your Glitch Developer Dashboard.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "title_token",
      "type": 2,
      "value": "",
      "description": "Your Title Token. Generated in the Technical Integration tab of your title.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "target_room",
      "type": 2,
      "value": "rm_main_menu",
      "description": "The name of the room to transition to after successful initialization (e.g. rm_main_menu).",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enable_auto_heartbeat",
      "type": 3,
      "value": "True",
      "description": "When ON, automatically sends a playtime heartbeat every 60 seconds to earn payouts. When OFF, call glitch_send_heartbeat() manually.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "enforce_validation",
      "type": 3,
      "value": "False",
      "description": "When ON, the game will display a blocking error screen if the player's license is invalid or the game was not launched from Glitch. Recommended for DRM-protected titles.",
      "resourceType": "GMExtensionOption"
    },
    {
      "name": "dev_test_install_id",
      "type": 2,
      "value": "",
      "description": "Developer testing only. Enter a valid install_id here to bypass URL detection during local testing. Leave blank for production builds.",
      "resourceType": "GMExtensionOption"
    }
  ],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "2.0.0",
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
          "name": "glitch_show_error",
          "externalName": "glitch_show_error",
          "kind": 2,
          "help": "glitch_show_error(message) — Shows the Glitch error overlay with a custom message.",
          "returnType": 2,
          "argCount": 1,
          "args": [1],
          "resourceType": "GMExtensionFunction"
        },
        {
          "name": "glitch_dismiss_error",
          "externalName": "glitch_dismiss_error",
          "kind": 2,
          "help": "glitch_dismiss_error() — Dismisses the error overlay (only works if EnforceValidation is OFF).",
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
