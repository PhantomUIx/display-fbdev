const std = @import("std");
const builtin = @import("builtin");
const phantom = @import("phantom");

pub const phantomOptions = struct {
    pub const displayBackends = struct {
        pub const fbdev = @import("phantom.display.fbdev").display.backends.fbdev;
    };
};

const alloc = if (builtin.link_libc) std.heap.c_allocator else std.heap.page_allocator;

pub fn main() !void {
    var display = phantom.display.Backend(.fbdev).Display.init(alloc, .compositor);
    defer display.deinit();

    const outputs = try @constCast(&display.display()).outputs();
    defer outputs.deinit();

    for (outputs.items) |output| {
        std.debug.print("{}\n", .{output});
        const surface = try output.createSurface(.output, .{
            .size = (try output.info()).size.res,
        });
        defer {
            surface.destroy() catch {};
            surface.deinit();
        }
    }
}
