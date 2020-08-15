const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "");
    @cInclude("GLFW/glfw3.h");
    @cInclude("flextgl/flextGL.h");
    @cInclude("sokol/sokol_gfx.h");
    @cInclude("Handmade-Math/HandmadeMath.h");
});

const std = @import("std");

const GlfwError = error {
    FailedInitialization,
    FailedWindowCreation
};

// var window : *c.GLFWwindow = undefined;

export fn errorCallback(err: c_int, description: [*c]const u8) void {
    std.debug.panic("Error: {}\n", .{description});
}

pub fn main() !void {
    _ = c.glfwSetErrorCallback(errorCallback);

    if (c.glfwInit() == c.GLFW_FALSE) {
        return GlfwError.FailedInitialization;
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    var window : *c.GLFWwindow = c.glfwCreateWindow(1280, 720, "Awesome title", null, null) 
                                 orelse return GlfwError.FailedWindowCreation;
    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);
    _ = c.flextInit();

    var desc = std.mem.zeroes(c.sg_desc);
    c.sg_setup(&desc);
    std.debug.assert(c.sg_isvalid());
    defer c.sg_shutdown();

    var pass_action = std.mem.zeroes(c.sg_pass_action);
    pass_action.colors[0] = .{ 
        .action = .SG_ACTION_CLEAR, 
        .val = .{ 0.0, 1.0, 0.0, 1.0 } 
    };
    
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE)
    {
        var b = pass_action.colors[0].val[2] + 0.01;
        pass_action.colors[0].val[2] = if (b > 1.0) 0.0 else b;

        var cur_width: c_int = undefined;
        var cur_height: c_int = undefined;
        c.glfwGetFramebufferSize(window, &cur_width, &cur_height);
        {
            c.sg_begin_default_pass(&pass_action, cur_width, cur_height);
            defer c.sg_end_pass();
        }
        c.sg_commit();
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}