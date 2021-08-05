const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("tracy", "src/main.zig");
    lib.setBuildMode(mode);
    lib.addIncludeDir("tracy");

    const tracy_enable = b.option(bool, "tracy", "Enable Tracy integration.") orelse false;
    if (tracy_enable) {
        lib.addCSourceFile("tracy/TracyClient.cpp",
                           &.{"-DTRACY_ENABLE=1", "-fno-sanitize=undefined"});
    }

    lib.install();

    var main_tests = b.addTest("src/main.zig");
    main_tests.addIncludeDir("tracy");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}
