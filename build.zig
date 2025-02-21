const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .wasi,
        .cpu_features_add = std.Target.wasm.featureSet(&.{ .atomics, .bulk_memory }),
    });
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "thread",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = false,
    });
    exe.shared_memory = true;
    exe.export_memory = true;
    exe.import_memory = true;
    exe.max_memory = std.wasm.page_size * 1280;
    exe.rdynamic = true;
    b.installArtifact(exe);
}
