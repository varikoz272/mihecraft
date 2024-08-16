const rl = @import("raylib.zig");

pub fn Camera(comptime T: CameraType) type {
    return struct {
        const Self = @This();
        const Type = T;

        tag: []const u8,
        cam: *rl.Camera,

        pub fn Init(cam: *rl.Camera, tag: []const u8) Self {
            return Self{
                .tag = tag,
                .cam = cam,
            };
        }

        pub fn Update(self: Self) void {
            const start_copy = self.cam.*;

            rl.UpdateCamera(self.cam, Type.value());

            if (Type == .STATIC) self.cam.* = start_copy;
        }
    };
}

pub const CameraType = enum(c_int) {
    FIRST_PERSON = rl.CAMERA_FIRST_PERSON,
    STATIC = rl.CAMERA_FREE,

    pub fn from(raylib_type: c_int) CameraType {
        return @enumFromInt(raylib_type);
    }

    pub fn value(self: CameraType) c_int {
        return @intFromEnum(self);
    }
};
