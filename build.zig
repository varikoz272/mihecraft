const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    if (target.result.os.tag != .windows) @panic("Unsupported OS (check build.zig)");
    const optimize = b.standardOptimizeOption(.{});

    const name = "mihecraft";

    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    exe.linkLibC();

    exe.addIncludePath(b.path("./include/"));
    exe.addIncludePath(b.path("./include/external"));
    exe.addIncludePath(b.path("./include/external/glfw/include"));

    exe.addObjectFile(b.path("./lib/raylib.lib"));
    exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("opengl32");

    exe.defineCMacro("PLATFORM_DESKTOP", null);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    //====================================================== UNIT TESTS =================================

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/test.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    //====================================================== /UNIT TESTS ================================

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_exe_unit_tests.step);
    run_step.dependOn(&run_cmd.step);
}
