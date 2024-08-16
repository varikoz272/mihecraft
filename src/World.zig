const rl = @import("raylib.zig");
const block = @import("Block.zig");
const std = @import("std");

pub fn CakeWorld(comptime width: usize, comptime length: usize) type {
    return struct {
        const Self = @This();

        const Width = width;
        const Length = length;

        combo: block.BlockCombo(Width * Length),
        allocator: std.mem.Allocator,

        pub fn Generate(allocator: std.mem.Allocator) Self {
            var self = Self{
                .combo = block.BlockCombo(Width * Length).init(allocator),
                .allocator = allocator,
            };
            self.FillLayers();
            return self;
        }

        pub fn Destroy(self: Self) void {
            self.combo.Destroy();
        }

        fn FillLayers(self: *Self) void {
            const maximum_per_layer = self.combo.GetCapacity();

            for (0..maximum_per_layer) |i| {
                self.combo.stone.append(block.Block(.Stone).init(block.BlockLocation().init(0, 0, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.water.append(block.Block(.Water).init(block.BlockLocation().init(0, 1, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.sand.append(block.Block(.Sand).init(block.BlockLocation().init(0, 2, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.grass.append(block.Block(.Grass).init(block.BlockLocation().init(0, 3, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
            }
        }

        pub fn Draw(self: Self) void {
            const grass_blocks = &self.combo.grass.items;
            const stone_blocks = &self.combo.stone.items;
            const sand_blocks = &self.combo.sand.items;
            const water_blocks = &self.combo.water.items;

            for (0..self.combo.GetCapacity()) |i| {
                if (i < grass_blocks.len) grass_blocks.*[i].DrawSimple();
                if (i < stone_blocks.len) stone_blocks.*[i].DrawSimple();
                if (i < sand_blocks.len) sand_blocks.*[i].DrawSimple();
                if (i < water_blocks.len) water_blocks.*[i].DrawSimple();
            }
        }
    };
}

pub fn FlatWorld(comptime width: usize, comptime length: usize) type {
    return struct {
        const Self = @This();
        const Width = width;
        const Length = length;

        blocks: [Width * Length]block.Block(.Grass),

        pub fn Generate() Self {
            return Self{
                .blocks = generateFlatSurface(0, Width, Length),
            };
        }

        /// Before drawing, rl.BeginDrawing and rl.Begin3DMode should be called
        pub fn Draw(self: Self) void {
            for (self.blocks) |cur_block| {
                cur_block.DrawSimple();
            }
        }
    };
}

fn generateFlatSurface(y: i32, comptime width: usize, comptime length: usize) [width * length]block.Block(.Grass) {
    var surface: [width * length]block.Block(.Grass) = undefined;

    for (0..width) |x| {
        for (0..length) |z|
            surface[x + z * width] = block.Block(.Grass).init(block.BlockLocation().init(@intCast(x), y, @intCast(z)));
    }

    return surface;
}
