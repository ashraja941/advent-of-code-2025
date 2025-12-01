const std = @import("std");

pub fn build(b: *std.Build) !void {
    const allocator = b.allocator;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/common.zig"),
        .target = target,
    });

    const all_tests = b.step("test", "Run all tests");

    var sourceDirectory = try std.fs.cwd().openDir("./src", .{ .iterate = true });
    var it = sourceDirectory.iterate();

    while (try it.next()) |entry| {
        if (entry.kind == .directory and entry.name[0] != '.') {
            const subfolderPath = try std.fs.path.join(allocator, &.{ "src", entry.name });
            const sourceFile = try std.fs.path.join(allocator, &.{ subfolderPath, "main.zig" });

            _ = std.fs.cwd().openFile(sourceFile, .{}) catch continue;

            const exe = b.addExecutable(.{
                .name = entry.name,
                .root_module = b.createModule(.{
                    .root_source_file = b.path(sourceFile),
                    .target = target,
                    .optimize = optimize,
                }),
            });

            exe.root_module.addImport("common", mod);
            b.installArtifact(exe);

            const run_cmd = b.addRunArtifact(exe);
            run_cmd.step.dependOn(b.getInstallStep());

            const run_name = try std.fmt.allocPrint(allocator, "run_{s}", .{entry.name});
            const run_description = try std.fmt.allocPrint(allocator, "Run the app for day {s}", .{entry.name});
            const run_step = b.step(run_name, run_description);
            run_step.dependOn(&run_cmd.step);

            const exe_unit_tests = b.addTest(.{
                .root_module = b.createModule(.{
                    .root_source_file = b.path(sourceFile),
                    .target = target,
                    .optimize = optimize,
                }),
            });

            exe_unit_tests.root_module.addImport("common", mod);

            const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

            const test_name = try std.fmt.allocPrint(allocator, "test_{s}", .{entry.name});
            const test_description = try std.fmt.allocPrint(allocator, "Run unit tests for day {s}", .{entry.name});
            const test_step = b.step(test_name, test_description);
            test_step.dependOn(&run_exe_unit_tests.step);

            all_tests.dependOn(test_step);
        }
    }
}
