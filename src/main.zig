const std = @import("std");
const rl = @import("raylib.zig");
const gn = @import("generation.zig");

const SCREEN_WIDTH: c_int = 1920;
const SCREEN_HEIGHT: c_int = 1080;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const world = try gn.perlin_noise_world(gpa.allocator());

    var cam = rl.Camera{
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .fovy = 90,
        .target = .{ .x = 1, .y = 0, .z = 0 },
        .position = .{ .x = 0, .y = 5, .z = 0 },
        .projection = rl.CAMERA_PERSPECTIVE,
    };

    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "mihecraft");
    rl.ToggleFullscreen();
    rl.DisableCursor();
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.ClearBackground(rl.GRAY);
        rl.UpdateCamera(&cam, rl.CAMERA_FREE);

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.DrawFPS(10, 10);

        rl.BeginMode3D(cam);
        defer rl.EndMode3D();
        drawWorld(world);
    }

    rl.CloseWindow();
}

pub fn drawWorld(world: gn.World()) void {
    for (world.positions.items) |pos| {
        const block = world.blockAt(pos) orelse unreachable;
        const color = block.color();
        rl.DrawCube(pos, 1.0, 1.0, 1.0, color);
        rl.DrawCubeWires(pos, 1.0, 1.0, 1.0, rl.BLACK);
    }
}
