const rl = @import("raylib.zig");
const std = @import("std");
const block = @import("Block.zig");

/// Generates structure from 0,0,0 (shift if needed)
pub fn River(comptime T: block.BlockType, len: usize, seed: u64, allocator: std.mem.Allocator) []block.Block(T) {
    var prng = std.Random.DefaultPrng.init(seed);
    const rand = prng.random();

    const river: []block.Block(T) = allocator.alloc(block.Block(T), len) catch @panic("Out of memory on appending std.Arraylist");

    for (river, 0..) |*cur_block, x| {
        cur_block.* = block.Block(T).init(block.BlockLocation().init(@intCast(x), 0, 0));
    }

    const angle = rand.float(f32);
    rotateFromBeginToEnd(T, river, angle);

    return river;
}

fn rotateWithCenter(comptime T: block.BlockType, structure: []block.Block(T), angle: f32, r: f32, center: block.BlockLocation()) void {
    const center_f32 = center.ToRl();

    for (structure) |*cur_block| {
        cur_block.location.x = @intFromFloat(center_f32.x + r * @cos(angle));
        cur_block.location.y = @intFromFloat(center_f32.y + r * @sin(angle));
    }
}

fn rotateFromBeginToEnd(comptime T: block.BlockType, structure: []block.Block(T), angle: f32) void {
    const r: f32 = structure[0].location.SpaceBetween(structure[1].location);
    const center = structure[0].location;
    rotateWithCenter(T, structure, angle, r, center);
}
