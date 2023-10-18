const std = @import("std");
const builtin = @import("builtin");
const Build = std.Build;

const rp2040 = @import("rp2040");
// const uf2 = @import("uf2");

pub fn uf2_from_elf(dep: *Build.Dependency, exe: *Build.CompileStep) Build.LazyPath {
    const b = dep.builder;
    const elf2uf2_run = b.addRunArtifact(dep.artifact("elf2uf2"));
    elf2uf2_run.addArgs(&.{ "--family-id", "RP2040" });
    elf2uf2_run.addArg("--elf-path");
    elf2uf2_run.addArtifactArg(exe);
    elf2uf2_run.addArg("--output-path");
    const uf2_file = elf2uf2_run.addPrefixedOutputFileArg("", "test.uf2");
    return uf2_file;
}

pub fn build(b: *Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    _ = target;

    const uf2_dep = b.dependency("uf2", .{});
    {
        const exe = rp2040.addPiPicoExecutable(b, .{
            .name = "blinky",
            .source_file = .{ .path = "src/main.zig" },
            .optimize = optimize,
        });
        exe.installArtifact(b);

        const uf2_file = uf2_from_elf(uf2_dep, exe.inner);
        const install_uf2 = b.addInstallFile(uf2_file, "bin/blinky.uf2");
        b.getInstallStep().dependOn(&install_uf2.step);
    }
}
