function glitch_js_get_url_param(name) {
    const params = new URLSearchParams(window.location.search);
    return params.get(name) || "";
}
