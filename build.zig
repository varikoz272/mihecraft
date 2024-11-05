const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
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

    exe.addIncludePath(b.path("include/"));
    exe.addIncludePath(b.path("include/external"));
    exe.addIncludePath(b.path("include/external/glfw/include"));

    exe.addObjectFile(switch (target.result.os.tag) {
        .windows => b.path("lib/raylib.lib"),
        .linux => b.path("lib/libraylib.a"),
        .macos => b.path("lib/libraylib.a"),
        .emscripten => b.path("lib/libraylib.a"),
        else => @panic("Unsupported OS"),
    });

    switch (target.result.os.tag) {
        .windows => {
            exe.linkSystemLibrary("winmm");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("opengl32");

            exe.defineCMacro("PLATFORM_DESKTOP", null);
        },
        .linux => {
            exe.linkSystemLibrary("GL");
            exe.linkSystemLibrary("rt");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
            exe.linkSystemLibrary("X11");

            exe.defineCMacro("PLATFORM_DESKTOP", null);
        },
        .macos => {
            exe.linkFramework("Foundation");
            exe.linkFramework("Cocoa");
            exe.linkFramework("OpenGL");
            exe.linkFramework("CoreAudio");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("IOKit");

            exe.defineCMacro("PLATFORM_DESKTOP", null);
        },
        else => @panic("Unsupported OS"),
    }

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
