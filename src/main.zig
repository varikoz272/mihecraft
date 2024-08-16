const rl = @import("raylib.zig");
const std = @import("std");
const light = @import("Light.zig");
const model = @import("Model.zig");
const camera = @import("Camera.zig");
const block = @import("Block.zig");

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
    const cube = block.Block(.Water).init(block.BlockLocation().init(0, 0, 0));

    rl.SetTargetFPS(60);
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "mihecraft");
    rl.ToggleFullscreen();
    rl.DisableCursor();

    // try std.io.getStdOut().writer().print("\n\nSIZE OF BLOCK WITH LOCATION {}\n\n", .{@sizeOf(@TypeOf(block.Block(.Grass).init(block.BlockLocation().init(0, 0, 0))))});
    // try std.io.getStdOut().writer().print("\n\nSIZE OF BLOCKTYPE {}\n\n", .{@sizeOf(block.BlockType)});
    // try std.io.getStdOut().writer().print("\n\nSIZE OF BLOCK LOCATION {}\n\n", .{@sizeOf(block.BlockLocation())});

    while (!rl.WindowShouldClose()) {
        cam.Update();

        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.GRAY);
        rl.DrawFPS(10, 10);

        rl.BeginMode3D(cam.cam.*);
        defer rl.EndMode3D();

        cube.DrawSimple();
    }

    rl.CloseWindow();
}
