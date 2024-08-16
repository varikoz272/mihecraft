const rl = @import("raylib.zig");
const std = @import("std");
const light = @import("Light.zig");
const model = @import("Model.zig");
const camera = @import("Camera.zig");

const SCREEN_WIDTH: c_int = 1920;
const SCREEN_HEIGHT: c_int = 1080;

pub fn main() !void {
    var cameraBuffer = rl.Camera{
        .fovy = 60,
        .position = .{ .x = 0, .y = 10, .z = 0 },
        .target = .{ .x = 0, .y = 0, .z = 1 },
        .up = .{ .x = 0, .y = 1, .z = 0 },
        .projection = rl.CAMERA_PERSPECTIVE,
    };

    var cam = camera.Camera(camera.CameraType.from(rl.CAMERA_FIRST_PERSON)).Init(&cameraBuffer, "MAIN_CHARACTER");

    rl.SetTargetFPS(60);
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "mihecraft");
    rl.ToggleFullscreen();
    rl.DisableCursor();

    while (!rl.WindowShouldClose()) {
        cam.Update();

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.GRAY);
        rl.DrawFPS(10, 10);

        rl.BeginMode3D(cam.cam.*);
        defer rl.EndMode3D();

        rl.DrawPlane(rl.Vector3Zero(), .{ .x = 10, .y = 10 }, rl.RED);
    }

    rl.CloseWindow();
}
