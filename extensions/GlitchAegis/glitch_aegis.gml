#define glitch_init
/// @description Initializes the Glitch Aegis system.
global.glitch_title_id = extension_get_option_value("GlitchAegis", "title_id");
global.glitch_token = extension_get_option_value("GlitchAegis", "title_token");
global.glitch_install_id = "";

if (os_browser != browser_not_a_browser) {
    global.glitch_install_id = glitch_js_get_url_param("install_id");
} else {
    var _count = parameter_count();
    for (var i = 0; i < _count; i++) {
        if (parameter_string(i) == "--install_id" && i + 1 < _count) {
            global.glitch_install_id = parameter_string(i + 1);
        }
    }
}

#define glitch_send_heartbeat
if (global.glitch_install_id == "") return -1;
var _url = "https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/installs";
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
ds_map_add(_headers, "Content-Type", "application/json");
var _body = ds_map_create();
ds_map_add(_body, "user_install_id", global.glitch_install_id);
ds_map_add(_body, "platform", (os_browser != browser_not_a_browser) ? "web" : "pc");
var _req = http_request(_url, "POST", _headers, json_encode(_body));
ds_map_destroy(_headers); ds_map_destroy(_body);
return _req;

#define glitch_validate_license
if (global.glitch_install_id == "") return -1;
var _url = "https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/installs/" + global.glitch_install_id + "/validate";
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
var _req = http_request(_url, "POST", _headers, "");
ds_map_destroy(_headers);
return _req;

#define glitch_track_event
var _body = ds_map_create();
ds_map_add(_body, "game_install_id", global.glitch_install_id);
ds_map_add(_body, "step_key", argument0);
ds_map_add(_body, "action_key", argument1);
var _headers = ds_map_create();
ds_map_add(_headers, "Authorization", "Bearer " + global.glitch_token);
ds_map_add(_headers, "Content-Type", "application/json");
var _req = http_request("https://api.glitch.fun/api/titles/" + global.glitch_title_id + "/events", "POST", _headers, json_encode(_body));
ds_map_destroy(_headers); ds_map_destroy(_body);
return _req;
