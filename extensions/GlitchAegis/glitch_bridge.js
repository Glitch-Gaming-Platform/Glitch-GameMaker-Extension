// Glitch Aegis — JavaScript Bridge (HTML5 only)
// These functions are called from GML in web/HTML5 builds.

function glitch_js_get_url_param(name) {
    try {
        var params = new URLSearchParams(window.location.search);
        return params.get(name) || "";
    } catch (e) {
        return "";
    }
}

function glitch_js_get_user_agent() {
    try {
        return navigator.userAgent || "";
    } catch (e) {
        return "";
    }
}

function glitch_js_get_screen_info() {
    try {
        return window.screen.width + "x" + window.screen.height;
    } catch (e) {
        return "0x0";
    }
}
