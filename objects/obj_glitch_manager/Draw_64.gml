// obj_glitch_manager — Draw GUI Event
// ─────────────────────────────────────
// Renders the Glitch error overlay when an error is active.
// Draws on top of everything because this is a GUI event.
// The overlay blocks interaction when EnforceValidation is ON.

if (!global.glitch_error_active) exit;

var _sw = display_get_gui_width();
var _sh = display_get_gui_height();

// ── Dark overlay background ───────────────────────────────────────────────────
draw_set_alpha(0.92);
draw_set_color(c_black);
draw_rectangle(0, 0, _sw, _sh, false);

// ── Glitch brand panel ────────────────────────────────────────────────────────
var _pw = 560;
var _ph = 340;
var _px = (_sw - _pw) / 2;
var _py = (_sh - _ph) / 2;

draw_set_alpha(1.0);
draw_set_color(make_color_rgb(18, 18, 24));
draw_rectangle(_px, _py, _px + _pw, _py + _ph, false);

// Border
draw_set_color(make_color_rgb(220, 50, 80)); // Glitch red
draw_rectangle(_px, _py, _px + _pw, _py + _ph, true);

// ── Icon / Header ─────────────────────────────────────────────────────────────
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(220, 50, 80));
draw_set_font(-1); // Default font

var _cx = _px + _pw / 2;

// Title bar
draw_set_color(make_color_rgb(220, 50, 80));
draw_rectangle(_px, _py, _px + _pw, _py + 48, false);
draw_set_color(c_white);
draw_text(_cx, _py + 14, "⚠  GLITCH AEGIS — ACCESS ERROR");

// ── Error message ─────────────────────────────────────────────────────────────
draw_set_color(make_color_rgb(220, 220, 230));
draw_set_halign(fa_center);

// Split message on \n and draw each line
var _lines = string_split(global.glitch_error_message, "\n");
var _line_height = 28;
var _msg_y = _py + 72;

for (var i = 0; i < array_length(_lines); i++) {
    draw_text(_cx, _msg_y + (i * _line_height), _lines[i]);
}

// ── Footer / instructions ─────────────────────────────────────────────────────
var _footer_y = _py + _ph - 64;

draw_set_color(make_color_rgb(100, 100, 120));
draw_line(_px + 20, _footer_y, _px + _pw - 20, _footer_y);

if (global.glitch_enforce_validation) {
    // Enforced: can't dismiss — show visit prompt
    draw_set_color(make_color_rgb(180, 180, 200));
    draw_text(_cx, _footer_y + 10, "Visit  glitch.fun  to play this game.");
    draw_set_color(make_color_rgb(100, 100, 120));
    draw_text(_cx, _footer_y + 34, "The game cannot continue without a valid Glitch session.");
} else {
    // Not enforced: show dismiss hint
    draw_set_color(make_color_rgb(180, 180, 200));
    draw_text(_cx, _footer_y + 10, "Visit  glitch.fun  for the best experience.");
    draw_set_color(make_color_rgb(120, 200, 120));
    draw_text(_cx, _footer_y + 34, "Press  ENTER  or  SPACE  to continue anyway.");
    
    // Dismiss on key press (non-enforced only)
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
        glitch_dismiss_error();
    }
}

// Reset draw state
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
