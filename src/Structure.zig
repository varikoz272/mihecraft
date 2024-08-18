const rl = @import("raylib.zig");
const std = @import("std");
const block = @import("Block.zig");
const c = @cImport(@cInclude("stdio.h"));

/// Generates structure from 0,0,0 (shift if needed)
pub fn River(comptime T: block.BlockType, len: usize, seed: u64, allocator: std.mem.Allocator) []block.Block(T) {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    var river: []block.Block(T) = allocator.alloc(block.Block(T), len) catch @panic("Out of memory on appending std.Arraylist");

    for (river, 0..) |*cur_block, x| {
        cur_block.* = block.Block(T).init(block.BlockLocation().init(@intCast(x), 0, 0));
    }

    const angle = rand.float(f32) * 360;
    rotateFromBeginToEnd(T, &river, angle);
    swizzleStraightByX(T, &river);

    return river;
}

// fn rotateSingle(comptime T: block.BlockType, single_block: *block.Block(T), angle, center: block.BlockLocation()) void {
//
// }

fn rotateWithCenter(comptime T: block.BlockType, structure: *[]block.Block(T), angle: f32, center: block.BlockLocation()) void {
    const center_f32 = center.ToRl();
    const theta: f32 = angle * std.math.pi / 180.0;

    for (structure.*) |*cur_block| {
        const cur_block_f32 = cur_block.location.ToRl();
        std.io.getStdOut().writer().print("\n\nold x = {} | z = {}", .{ cur_block.location.x, cur_block.location.z }) catch @panic("");
        cur_block.location.x = @intFromFloat(center_f32.x + @cos(theta) * (cur_block_f32.x - center_f32.x) - @sin(theta) * (cur_block_f32.z - center_f32.z));
        cur_block.location.z = @intFromFloat(center_f32.z + @sin(theta) * (cur_block_f32.x - center_f32.x) + @cos(theta) * (cur_block_f32.z - center_f32.z));
        std.io.getStdOut().writer().print("\nnew x = {} | z = {}", .{ cur_block.location.x, cur_block.location.z }) catch @panic("");
    }
}

fn rotateFromBeginToEnd(comptime T: block.BlockType, structure: *[]block.Block(T), angle: f32) void {
    const center = structure.*[0].location;
    rotateWithCenter(T, structure, angle, center);
}

fn swizzleStraightByX(comptime T: block.BlockType, structure: *[]block.Block(T)) void {
    var theta: f32 = 0;

    for (structure.*) |*item| {
        const theta_sin = @sin(theta);
        const loc_f32 = item.location.ToRl();
        item.location.x = @intFromFloat(loc_f32.x + theta_sin * 5);

        theta += 0.03;
    }
}
