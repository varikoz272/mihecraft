const rl = @import("raylib.zig");

pub fn Block(comptime T: BlockType) type {
    return struct {
        const Self = @This();
        const Type = T;

        location: BlockLocation(),

        pub fn init(location: BlockLocation()) Self {
            return Self{
                .location = location,
            };
        }

        /// Before drawing, rl.BeginDrawing and rl.Begin3DMode should be called
        pub fn DrawSimple(self: Self) void {
            rl.DrawCube(self.location.ToRl(), 1.0, 1.0, 1.0, T.Color());
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
    };
}

pub const BlockType = enum(u4) {
    const Self = @This();

    Grass = 0,
    Stone = 1,

    pub fn Color(self: Self) rl.Color {
        switch (self) {
            .Grass => {
                return rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 };
            },
            .Stone => {
                return rl.Color{ .r = 127, .g = 127, .b = 127, .a = 255 };
            },
        }
    }
};
