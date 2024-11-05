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

pub fn World() type {
    return struct {
        const Self = @This();

        blocks: std.StringHashMap(BlockType),
        positions: std.ArrayList(rl.Vector3),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .blocks = std.StringHashMap(BlockType).init(allocator),
                .positions = std.ArrayList(rl.Vector3).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn putBlock(self: *Self, pos: rl.Vector3, T: BlockType) std.mem.Allocator.Error!void {
            try self.positions.append(pos);
            errdefer _ = self.positions.orderedRemove(self.positions.items.len - 1);

            var hash = try self.allocator.alloc(u8, 15);
            bufBlockHash(hash[0..hash.len], pos.x, pos.y, pos.z);
            try self.blocks.put(hash[0..hash.len], T);
        }

        pub fn blockAt(self: Self, pos: rl.Vector3) ?BlockType {
            var hash: [15]u8 = undefined;
            bufBlockHash(hash[0..hash.len], pos.x, pos.y, pos.z);
            return self.blocks.get(hash[0..hash.len]);
        }

        fn bufBlockHash(buf: []u8, x: f32, y: f32, z: f32) void {
            _ = std.fmt.bufPrint(buf[0..buf.len], "{d:.3}{d:.3}{d:.3}", .{ x, y, z }) catch unreachable;
        }

        pub fn deinit(self: *Self) void {
            self.positions.deinit();

            var iter = self.blocks.iterator();
            while (iter.next()) |entry| self.allocator.free(entry.key_ptr);

            self.blocks.deinit();
        }
    };
}

pub fn flat_world(allocator: std.mem.Allocator) std.mem.Allocator.Error!World() {
    var world = World().init(allocator);
    for (0..10) |x| {
        for (0..10) |z| try world.putBlock(rl.Vector3{
            .x = @floatFromInt(x),
            .y = 0.0,
            .z = @floatFromInt(z),
        }, .Grass);
    }

    return world;
}