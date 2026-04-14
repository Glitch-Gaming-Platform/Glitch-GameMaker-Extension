// Glitch Aegis — JavaScript Bridge (HTML5 only)
// These functions are called from GML in web/HTML5 builds.
// Bind explicitly onto the global object so GameMaker can always resolve them.

(function (root) {
    function safeUrlParam(name) {
        try {
            var params = new URLSearchParams(root.location.search);
            return params.get(name) || "";
        } catch (e) {
            return "";
        }
    }

    function safeUserAgent() {
        try {
            return root.navigator && root.navigator.userAgent ? root.navigator.userAgent : "";
        } catch (e) {
            return "";
        }
    }

    function safeScreenInfo() {
        try {
            var screenObj = root.screen || {};
            return String(screenObj.width || 0) + "x" + String(screenObj.height || 0);
        } catch (e) {
            return "0x0";
        }
    }

    root.glitch_js_get_url_param = safeUrlParam;
    root.glitch_js_get_user_agent = safeUserAgent;
    root.glitch_js_get_screen_info = safeScreenInfo;

    // Also declare named functions for runners that resolve by symbol name.
    function glitch_js_get_url_param(name) { return safeUrlParam(name); }
    function glitch_js_get_user_agent() { return safeUserAgent(); }
    function glitch_js_get_screen_info() { return safeScreenInfo(); }

    root.__glitch_aegis_bridge_loaded = true;
})(typeof globalThis !== "undefined" ? globalThis : (typeof window !== "undefined" ? window : this));
