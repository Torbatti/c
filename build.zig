const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const DEFAULT_C_FLAGS = [_][]const u8{ "-std=c11", "-Wall", "-Wextra", "-pedantic" };

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("src/root_c.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    exe_mod.addIncludePath(b.path("include/"));
    exe_mod.addCSourceFile(.{
        .file = b.path("src/main.c"),
        .flags = &DEFAULT_C_FLAGS ++ &[_][]const u8{""},
    });
    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "root_c",
        .root_module = lib_mod,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    exe_mod.linkLibrary(lib);

    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = exe_mod,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
