const rl = @import("raylib.zig");
const std = @import("std");

const SCREEN_WIDTH: c_int = 1920;
const SCREEN_HEIGHT: c_int = 1080;

pub fn main() !void {
    rl.SetTargetFPS(60);
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "mihecraft");
    rl.ToggleFullscreen();
    rl.DisableCursor();
}
