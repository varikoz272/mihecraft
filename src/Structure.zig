const rl = @import("raylib.zig");
const std = @import("std");
const block = @import("Block.zig");
const c = @cImport(@cInclude("stdio.h"));

/// Generates structure from 0,0,0 (shift if needed)
pub fn River(comptime T: block.Type, len: usize, seed: u64, allocator: std.mem.Allocator) []block.Block(T) {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    var river: []block.Block(T) = allocator.alloc(block.Block(T), len) catch @panic("Out of memory on appending std.Arraylist");
    const angle = rand.float(f32) * 360;
    _ = angle;

    for (river, 0..) |*cur_block, x| {
        cur_block.* = block.Block(T).init(block.Location().init(@intCast(x), 0, 0));
        // rotateSingle(T, cur_block, angle, river[0].location);
    }

    // rotateFromBeginToEnd(T, &river, angle);
    swizzleStraightAlongX(T, &river);

    return river;
}

fn rotate(target: *block.Location(), angle_rad: f32, center_loc: rl.Vector3) void {
    const target_f32 = target.ToF32();

    target.x = @intFromFloat(center_loc.x + @cos(angle_rad) * (target_f32.x - center_loc.x) - @sin(angle_rad) * (target_f32.z - center_loc.z));
    target.z = @intFromFloat(center_loc.z + @sin(angle_rad) * (target_f32.x - center_loc.x) + @cos(angle_rad) * (target_f32.z - center_loc.z));
}

fn rotateSingle(comptime T: block.Type, single_block: *block.Block(T), angle: f32, center: block.Location()) void {
    const center_f32 = center.ToF32();
    const theta = rad(angle);
    rotate(&single_block.location, theta, center_f32);
}

fn rotateWithCenter(comptime T: block.Type, structure: *[]block.Block(T), angle: f32, center: block.Location()) void {
    for (structure.*) |*cur_block| {
        rotateSingle(T, cur_block, angle, center);
    }
}

fn rotateFromBeginToEnd(comptime T: block.Type, structure: *[]block.Block(T), angle: f32) void {
    rotateWithCenter(T, structure, angle, structure.*[0].location);
}

fn swizzleStraightAlongX(comptime T: block.Type, structure: *[]block.Block(T)) void {
    var theta: f32 = 0;

    for (structure.*) |*item| {
        const theta_sin = @sin(theta);
        const loc_f32 = item.location.ToF32();
        item.location.z = @intFromFloat(loc_f32.z + theta_sin * 5);

        theta += 0.03;
    }
}

fn rad(angle: f32) f32 {
    return angle * std.math.pi / 180.0;
}
