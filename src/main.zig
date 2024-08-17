const rl = @import("raylib.zig");
const std = @import("std");
const camera = @import("Camera.zig");
const block = @import("Block.zig");
const world = @import("World.zig");

const SCREEN_WIDTH: c_int = 1920;
const SCREEN_HEIGHT: c_int = 1080;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var cameraBuffer = rl.Camera{
        .fovy = 60,
        .position = .{ .x = 0, .y = 100, .z = 0 },
        .target = .{ .x = 0, .y = 0, .z = 1 },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .projection = rl.CAMERA_PERSPECTIVE,
    };

    var seed: u64 = 0;

    var cam = camera.Camera(camera.CameraType.from(rl.CAMERA_FIRST_PERSON)).Init(&cameraBuffer, "MAIN_CHARACTER");
    var w = world.SingleStructureWorld(500).Generate(seed, gpa.allocator());

    rl.SetTargetFPS(60);
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "mihecraft");
    rl.ToggleFullscreen();
    rl.DisableCursor();

    while (!rl.WindowShouldClose()) {
        if (rl.IsKeyDown(rl.KEY_G)) {
            seed +%= 1;
            w.Destroy();
            w = world.SingleStructureWorld(500).Generate(seed, gpa.allocator());
        }

        cam.Update();

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.GRAY);
        rl.DrawFPS(10, 10);

        rl.BeginMode3D(cam.cam.*);
        defer rl.EndMode3D();

        w.Draw(cam.cam.position);
    }

    w.Destroy();

    rl.CloseWindow();
}
