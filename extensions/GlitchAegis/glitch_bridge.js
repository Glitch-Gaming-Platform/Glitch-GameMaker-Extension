function glitch_js_get_url_param(name) {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || "";
}

function glitch_js_get_user_agent() {
    return navigator.userAgent || "";
}

function glitch_js_get_screen_info() {
    return window.screen.width + "x" + window.screen.height;
}
