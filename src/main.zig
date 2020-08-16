const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", "");
    @cInclude("GLFW/glfw3.h");
    @cInclude("flextgl/flextGL.h");
    @cInclude("sokol/sokol_gfx.h");
});
const std = @import("std");
const hmmath = @import("hmmath.zig");
const cube_glsl = @import("shaders/cube.glsl.zig");

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

    var w_width: c_int = 1280;
    var w_height: c_int = 720;

    var window : *c.GLFWwindow = c.glfwCreateWindow(w_width, w_height, "Awesome title", null, null) 
                                 orelse return GlfwError.FailedWindowCreation;
    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);
    _ = c.flextInit();

    var desc = std.mem.zeroes(c.sg_desc);
    c.sg_setup(&desc);
    std.debug.assert(c.sg_isvalid());
    defer c.sg_shutdown();

    const vertices = [_]f32 {
        // positions        // colors
        -1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0, 
         1.0, -1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
         1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,
        -1.0,  1.0, -1.0,   1.0, 0.0, 0.0, 1.0,

        -1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
         1.0, -1.0,  1.0,   0.0, 1.0, 0.0, 1.0, 
         1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,
        -1.0,  1.0,  1.0,   0.0, 1.0, 0.0, 1.0,

        -1.0, -1.0, -1.0,   0.0, 0.0, 1.0, 1.0, 
        -1.0,  1.0, -1.0,   0.0, 0.0, 1.0, 1.0, 
        -1.0,  1.0,  1.0,   0.0, 0.0, 1.0, 1.0, 
        -1.0, -1.0,  1.0,   0.0, 0.0, 1.0, 1.0,

        1.0, -1.0, -1.0,    1.0, 0.5, 0.0, 1.0, 
        1.0,  1.0, -1.0,    1.0, 0.5, 0.0, 1.0, 
        1.0,  1.0,  1.0,    1.0, 0.5, 0.0, 1.0, 
        1.0, -1.0,  1.0,    1.0, 0.5, 0.0, 1.0,

        -1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0, 
        -1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0, 
         1.0, -1.0,  1.0,   0.0, 0.5, 1.0, 1.0, 
         1.0, -1.0, -1.0,   0.0, 0.5, 1.0, 1.0,

        -1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0, 
        -1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0, 
         1.0,  1.0,  1.0,   1.0, 0.0, 0.5, 1.0, 
         1.0,  1.0, -1.0,   1.0, 0.0, 0.5, 1.0
    };
    var vbdesc = std.mem.zeroes(c.sg_buffer_desc);
    vbdesc.size = vertices.len * @sizeOf(@TypeOf(vertices[0]));
    vbdesc.content = &vertices[0];
    var vbuf = c.sg_make_buffer(&vbdesc);

    const indices = [_]u16 {
        0, 1, 2,  0, 2, 3,
        6, 5, 4,  7, 6, 4,
        8, 9, 10,  8, 10, 11,
        14, 13, 12,  15, 14, 12,
        16, 17, 18,  16, 18, 19,
        22, 21, 20,  23, 22, 20
    };
    var ibdesc = std.mem.zeroes(c.sg_buffer_desc);
    ibdesc.type = .SG_BUFFERTYPE_INDEXBUFFER;
    ibdesc.size = indices.len * @sizeOf(@TypeOf(indices[0]));
    ibdesc.content = &indices[0];
    var ibuf = c.sg_make_buffer(&ibdesc);

    var bind = std.mem.zeroes(c.sg_bindings);
    bind.vertex_buffers[0] = vbuf;
    bind.index_buffer = ibuf;

    const sdesc = cube_glsl.shader_desc();
    var shader =  c.sg_make_shader( 
        @ptrCast([*]const c.sg_shader_desc, &sdesc)
    );

    var pipeline_desc = std.mem.zeroes(c.sg_pipeline_desc);
    pipeline_desc.layout.attrs[0].format = .SG_VERTEXFORMAT_FLOAT3;
    pipeline_desc.layout.attrs[1].format = .SG_VERTEXFORMAT_FLOAT4;
    pipeline_desc.layout.buffers[0].stride = 28;
    pipeline_desc.shader = shader;
    pipeline_desc.index_type = .SG_INDEXTYPE_UINT16;
    pipeline_desc.depth_stencil.depth_compare_func = .SG_COMPAREFUNC_LESS_EQUAL;
    pipeline_desc.depth_stencil.depth_write_enabled = true;
    pipeline_desc.rasterizer.cull_mode = .SG_CULLMODE_BACK;
    var pip = c.sg_make_pipeline(&pipeline_desc);

    var pass_action = std.mem.zeroes(c.sg_pass_action);
    pass_action.colors[0].action = .SG_ACTION_CLEAR;
    pass_action.colors[0].val = [_]f32{ 0.2, 0.2, 0.2, 1.0 };

    const degreeToRadian = 3.14159/180.0;
    const radians: f32 = 60 * degreeToRadian;
    var proj = hmmath.Mat4.initPerspective(radians, 
                                             @intToFloat(f32, w_width) / @intToFloat(f32, w_height), 
                                             0.01, 
                                             10.0);
    var view = hmmath.Mat4.initLookAt(hmmath.Vec3.init(0.0, 1.5, 6.0), 
                                        hmmath.Vec3.zero, 
                                        hmmath.Vec3.y_axis);
    var view_proj = hmmath.Mat4.mul(proj, view);

    var rx: f32 = 0.0;
    var ry: f32 = 0.0;
    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE)
    {
        rx += 1.0 * degreeToRadian;
        ry += 2.0 * degreeToRadian;
        var rxm = hmmath.Mat4.initAngleAxis(hmmath.Vec3.x_axis, rx);
        var rym = hmmath.Mat4.initAngleAxis(hmmath.Vec3.y_axis, ry);
        var model = hmmath.Mat4.mul(rxm, rym);
        var mvp = hmmath.Mat4.mul(view_proj, model);
        var cube_vs_params: cube_glsl.vs_params_t = .{
            .mvp = mvp.toArray(),
        };

        var cur_width: c_int = undefined;
        var cur_height: c_int = undefined;
        c.glfwGetFramebufferSize(window, &cur_width, &cur_height);
        {
            c.sg_begin_default_pass(&pass_action, cur_width, cur_height);
            defer c.sg_end_pass();
            c.sg_apply_pipeline(pip);
            c.sg_apply_bindings(&bind);
            c.sg_apply_uniforms(.SG_SHADERSTAGE_VS, 0, &cube_vs_params, @sizeOf(@TypeOf(cube_vs_params)));
            c.sg_draw(0, 36, 1);
        }
        c.sg_commit();
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}