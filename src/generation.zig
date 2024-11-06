const std = @import("std");
const rl = @import("raylib.zig");

pub const BlockType = enum(u16) {
    const Self = @This();

    Grass = 0,
    Water = 1,
    Dirt = 2,
    Stone = 3,

    pub fn color(self: Self) rl.Color {
        return switch (self) {
            .Grass => rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 },
            .Water => rl.Color{ .r = 0, .g = 0, .b = 255, .a = 255 },
            .Dirt => rl.Color{ .r = 255, .g = 64, .b = 0, .a = 255 },
            .Stone => rl.Color{ .r = 100, .g = 100, .b = 100, .a = 255 },
        };
    }
};

pub const WorldError = error{
    SameBlockPosition,
};

pub const Location = struct {
    const Self = @This();

    int_x: i32,
    int_y: i32,
    int_z: i32,

    float_x: u8,
    float_y: u8,
    float_z: u8,

    // TODO: unignore float
    pub fn asRlVector3(self: Self) rl.Vector3 {
        return rl.Vector3{
            .x = @floatFromInt(self.int_x),
            .y = @floatFromInt(self.int_y),
            .z = @floatFromInt(self.int_z),
        };
    }
};

pub fn World() type {
    return struct {
        const Self = @This();

        blocks: std.AutoHashMap(Location, BlockType),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .blocks = std.AutoHashMap(Location, BlockType).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn putBlock(self: *Self, pos: rl.Vector3, T: BlockType) (std.mem.Allocator.Error || WorldError)!void {
            const hash = block_hash(pos);

            if (self.blocks.get(hash)) |_| return WorldError.SameBlockPosition;

            try self.blocks.put(hash, T);
        }

        pub fn blockAt(self: Self, pos: rl.Vector3) ?BlockType {
            return self.blocks.get(block_hash(pos));
        }

        fn block_hash(pos: rl.Vector3) Location {
            const int_x: i32 = @intFromFloat(pos.x);
            const int_y: i32 = @intFromFloat(pos.y);
            const int_z: i32 = @intFromFloat(pos.z);

            const float_x: u8 = @intCast(@as(u256, @intFromFloat(pos.x * 100)) % 255);
            const float_y: u8 = @intCast(@as(u256, @intFromFloat(pos.y * 100)) % 255);
            const float_z: u8 = @intCast(@as(u256, @intFromFloat(pos.z * 100)) % 255);

            return Location{
                .int_x = int_x,
                .int_y = int_y,
                .int_z = int_z,

                .float_x = float_x,
                .float_y = float_y,
                .float_z = float_z,
            };
        }

        pub fn deinit(self: *Self) void {
            self.blocks.deinit();
        }
    };
}

pub fn perlin_noise_world(allocator: std.mem.Allocator) std.mem.Allocator.Error!World() {
    var world = World().init(allocator);
    const perlin_noise_img = rl.GenImagePerlinNoise(100, 100, 0, 0, 1.0);
    const perlin_noise_data: []rl.Color = @as([*]rl.Color, @ptrCast(perlin_noise_img.data.?))[0..@as(usize, @intCast(perlin_noise_img.width * perlin_noise_img.height))];
    for (0..@intCast(perlin_noise_img.width)) |x| {
        for (0..@intCast(perlin_noise_img.height)) |z| {
            const y: f32 = @floatFromInt(perlin_noise_data[z * @as(usize, @intCast(perlin_noise_img.width)) + x].r / 10);
            world.putBlock(rl.Vector3{ .x = @floatFromInt(x), .y = y, .z = @floatFromInt(z) }, .Grass) catch |err| {
                if (err == std.mem.Allocator.Error.OutOfMemory) return std.mem.Allocator.Error.OutOfMemory else unreachable;
            };
        }
    }

    return world;
}

pub fn flat_world(allocator: std.mem.Allocator) std.mem.Allocator.Error!World() {
    var world = World().init(allocator);
    for (0..10) |x| {
        for (0..10) |z| world.putBlock(rl.Vector3{ .x = @floatFromInt(x), .y = 0.0, .z = @floatFromInt(z) }, .Grass) catch |err| {
            if (err == std.mem.Allocator.Error.OutOfMemory) return std.mem.Allocator.Error.OutOfMemory else unreachable;
        };
    }

    return world;
}
