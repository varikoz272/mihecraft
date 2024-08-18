const rl = @import("raylib.zig");
const std = @import("std");

pub fn Block(comptime T: BlockType) type {
    return struct {
        pub const Self = @This();
        const Type = T;

        location: BlockLocation(),

        pub fn init(location: BlockLocation()) Self {
            return Self{
                .location = location,
            };
        }

        /// Before drawing, rl.BeginDrawing and rl.Begin3DMode should be called
        pub fn DrawSimple(self: Self, cam_location: rl.Vector3) void {
            rl.DrawCube(self.location.ToRl(), 1.0, 1.0, 1.0, T.Color());
            if (self.IsNear(cam_location)) rl.DrawCubeWires(self.location.ToRl(), 1.0, 1.0, 1.0, T.Darker());
        }

        pub fn IsNear(self: Self, cam_location: rl.Vector3) bool {
            const x1: f32 = @floatFromInt(self.location.x);
            const y1: f32 = @floatFromInt(self.location.y);
            const z1: f32 = @floatFromInt(self.location.z);

            const x2 = cam_location.x;
            const y2 = cam_location.y;
            const z2 = cam_location.z;

            return @sqrt(rl.powf(x2 - x1, 2) + rl.powf(y2 - y1, 2) + rl.powf(z2 - z1, 2)) < 10;
        }
    };
}

pub fn BlockLocation() type {
    return struct {
        const Self = @This();

        x: i32,
        y: i32,
        z: i32,

        pub fn init(x: i32, y: i32, z: i32) Self {
            return Self{
                .x = x,
                .y = y,
                .z = z,
            };
        }

        pub fn ToRl(self: Self) rl.Vector3 {
            return rl.Vector3{
                .x = @floatFromInt(self.x),
                .y = @floatFromInt(self.y),
                .z = @floatFromInt(self.z),
            };
        }

        pub fn SpaceBetweenXZ(self: Self, p: Self) f32 {
            const x0: f32 = @floatFromInt(self.x);
            const x1: f32 = @floatFromInt(p.x);
            const z0: f32 = @floatFromInt(self.z);
            const z1: f32 = @floatFromInt(p.z);

            return @sqrt(rl.powf(x1 - x0, 2.0) + rl.powf(z1 - z0, 2.0));
        }
    };
}

pub fn BlockCombo(capacity: usize) type {
    return struct {
        const Self = @This();
        const Capacity = capacity;

        allocator: std.mem.Allocator,

        grass: std.ArrayList(Block(.Grass)),
        stone: std.ArrayList(Block(.Stone)),
        sand: std.ArrayList(Block(.Sand)),
        water: std.ArrayList(Block(.Water)),

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .grass = std.ArrayList(Block(.Grass)).initCapacity(allocator, capacity) catch @panic("Out of memory on initializing std.Arraylist"),
                .stone = std.ArrayList(Block(.Stone)).initCapacity(allocator, capacity) catch @panic("Out of memory on initializing std.Arraylist"),
                .sand = std.ArrayList(Block(.Sand)).initCapacity(allocator, capacity) catch @panic("Out of memory on initializing std.Arraylist"),
                .water = std.ArrayList(Block(.Water)).initCapacity(allocator, capacity) catch @panic("Out of memory on initializing std.Arraylist"),
                .allocator = allocator,
            };
        }

        pub fn GetCapacity(self: Self) usize {
            _ = self;
            return capacity;
        }

        pub fn Destroy(self: Self) void {
            self.grass.deinit();
            self.stone.deinit();
            self.sand.deinit();
            self.water.deinit();
        }
    };
}

pub const BlockType = enum(u4) {
    const Self = @This();

    Grass = 0,
    Stone = 1,
    Sand = 2,
    Water = 3,

    pub fn Color(self: Self) rl.Color {
        switch (self) {
            .Grass => return rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 },
            .Stone => return rl.Color{ .r = 127, .g = 127, .b = 127, .a = 255 },
            .Sand => return rl.Color{ .r = 200, .g = 200, .b = 0, .a = 255 },
            .Water => return rl.Color{ .r = 0, .g = 32, .b = 255, .a = 127 },
        }
    }

    pub fn Darker(self: Self) rl.Color {
        const color = self.Color();
        const colorVec = rl.Vector3{
            .x = @floatFromInt(color.r),
            .y = @floatFromInt(color.r),
            .z = @floatFromInt(color.r),
        };

        const avg: f32 = (colorVec.x + colorVec.y + colorVec.z) / 3.0;
        return rl.Color{
            .r = @intFromFloat(colorVec.x - avg),
            .g = @intFromFloat(colorVec.y - avg),
            .b = @intFromFloat(colorVec.z - avg),
            .a = color.a,
        };
    }
};
