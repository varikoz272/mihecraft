const rl = @import("raylib.zig");
const block = @import("Block.zig");
const std = @import("std");
const stc = @import("Structure.zig");

pub fn SingleStructureWorld(size: usize) type {
    return struct {
        const Self = @This();
        pub const Size = size;

        allocator: std.mem.Allocator,

        seed: u64,
        single_struct: stc.Struct(.Water),

        pub fn Generate(seed: usize, allocator: std.mem.Allocator) Self {
            var self = Self{
                .single_struct = undefined,
                .allocator = allocator,
                .seed = seed,
            };

            self.Fill(allocator);

            return self;
        }

        pub fn Destroy(self: Self) void {
            self.single_struct.Destroy();
        }

        fn Fill(self: *Self, allocator: std.mem.Allocator) void {
            self.single_struct = stc.River(block.Type.Water, Size, self.seed, allocator);
        }

        pub fn Draw(self: Self, cam_location: rl.Vector3) void {
            for (self.single_struct.data) |cur_block| {
                cur_block.DrawSimple(cam_location);
            }
        }
    };
}

pub fn CakeWorld(comptime width: usize, comptime length: usize) type {
    return struct {
        const Self = @This();

        const Width = width;
        const Length = length;

        combo: block.Combo(Width * Length),
        allocator: std.mem.Allocator,

        pub fn Generate(allocator: std.mem.Allocator) Self {
            var self = Self{
                .combo = block.Combo(Width * Length).init(allocator),
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
                self.combo.stone.append(block.Block(.Stone).init(block.Location().init(0, 0, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.water.append(block.Block(.Water).init(block.Location().init(0, 1, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.sand.append(block.Block(.Sand).init(block.Location().init(0, 2, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
                self.combo.grass.append(block.Block(.Grass).init(block.Location().init(0, 3, @intCast(i)))) catch @panic("Out of memory on appending std.Arraylist");
            }
        }

        pub fn Draw(self: Self, cam_location: rl.Vector3) void {
            const grass_blocks = &self.combo.grass.items;
            const stone_blocks = &self.combo.stone.items;
            const sand_blocks = &self.combo.sand.items;
            const water_blocks = &self.combo.water.items;

            for (0..self.combo.GetCapacity()) |i| {
                if (i < grass_blocks.len) grass_blocks.*[i].DrawSimple(cam_location);
                if (i < stone_blocks.len) stone_blocks.*[i].DrawSimple(cam_location);
                if (i < sand_blocks.len) sand_blocks.*[i].DrawSimple(cam_location);
                if (i < water_blocks.len) water_blocks.*[i].DrawSimple(cam_location);
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
        pub fn Draw(self: Self, cam_location: rl.Vector3) void {
            for (self.blocks) |cur_block| {
                cur_block.DrawSimple(cam_location);
            }
        }
    };
}

fn generateFlatSurface(y: i32, comptime width: usize, comptime length: usize) [width * length]block.Block(.Grass) {
    var surface: [width * length]block.Block(.Grass) = undefined;

    for (0..width) |x| {
        for (0..length) |z|
            surface[x + z * width] = block.Block(.Grass).init(block.Location().init(@intCast(x), y, @intCast(z)));
    }

    return surface;
}
