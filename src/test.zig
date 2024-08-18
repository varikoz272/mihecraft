const std = @import("std");
const world = @import("World.zig");
const expect = std.testing.expect;

const MAX_WORLD_GENERATION_TIME_MILLIS: i64 = 1000;

test "world_generation_speed" {
    const start = std.time.milliTimestamp();
    _ = world.SingleStructureWorld(500);
    const finish = std.time.milliTimestamp();
    try expect(finish - start <= MAX_WORLD_GENERATION_TIME_MILLIS);
}
