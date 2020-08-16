const c = @cImport({
    @cInclude("sokol/sokol_gfx.h");
});
const std = @import("std");

pub const vs_params_t = struct {
    mvp: [16]f32,
};

pub fn shader_desc() c.sg_shader_desc {
    var sdesc = std.mem.zeroes(c.sg_shader_desc);
    sdesc.vs.uniform_blocks[0].size = @sizeOf(vs_params_t);
    sdesc.vs.uniform_blocks[0].uniforms[0].name = "mvp";
    sdesc.vs.uniform_blocks[0].uniforms[0].type = .SG_UNIFORMTYPE_MAT4;
    sdesc.vs.source =
    \\  #version 330
    \\  uniform mat4 mvp;
    \\  layout(location=0) in vec4 position;
    \\  layout(location=1) in vec4 color0;
    \\  out vec4 color;
    \\  void main() {
    \\      gl_Position = mvp * position;
    \\      color = color0;
    \\  }
    ;
    sdesc.fs.source = 
    \\  #version 330
    \\  in vec4 color;
    \\  out vec4 frag_color;
    \\  void main() {
    \\      frag_color = color;
    \\  }
    ;
    return sdesc;
}