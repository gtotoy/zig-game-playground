const Builder = @import("std").build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("main", "src/main.zig");
    exe.setBuildMode(mode);

    exe.addIncludeDir("C:/dev");

    const c89Flags = [_][]const u8{"-std=c89", "-Wno-incompatible-function-pointer-types"};
    exe.addCSourceFile("C:/dev/flextgl/flextGL.c", &c89Flags);

    exe.addIncludeDir(".");

    const c99Flags = [_][]const u8{"-std=c99"};
    exe.addCSourceFile("src/compile-artifact/sokol_gfx.c", &c99Flags);

    exe.addIncludeDir("C:/dev/glfw/include");
    exe.addLibPath("C:/dev/glfw/build/src/Release");

    exe.addIncludeDir("C:/dev/cimgui-1.77");
    exe.addLibPath("C:/dev/cimgui-1.77/cimgui/build/Release");

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");

    // exe.install();

    const run_cmd = exe.run();
    // run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}