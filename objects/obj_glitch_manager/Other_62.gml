var _id = ds_map_find_value(async_load, "id");
if (_id == validation_req) {
    var _code = ds_map_find_value(async_load, "http_status");
    if (_code == 403) {
        show_message_async("Aegis Security: No valid license found. Please launch from Glitch.");
        game_end();
    }
}
