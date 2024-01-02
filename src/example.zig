const std = @import("std");
const builtin = @import("builtin");
const options = @import("options");
const phantom = @import("phantom");
const vizops = @import("vizops");

pub const phantomOptions = struct {
    pub const displayBackends = struct {
        pub const fbdev = @import("phantom.display.fbdev").display.backends.fbdev;
    };
};

const alloc = if (builtin.link_libc) std.heap.c_allocator else std.heap.page_allocator;

const sceneBackendType: phantom.scene.BackendType = @enumFromInt(@intFromEnum(options.scene_backend));
const sceneBackend = phantom.scene.Backend(sceneBackendType);

pub fn main() !void {
    const colors: []const [17]vizops.color.Any = &.{
        .{
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xf7, 0x76, 0x8e, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xff, 0x9e, 0x64, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xe0, 0xaf, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9e, 0xce, 0x6a, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x73, 0xda, 0xca, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xb4, 0xf9, 0xf8, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x2a, 0xc3, 0xde, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7d, 0xcf, 0xff, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7a, 0xa2, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xbb, 0x9a, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xc0, 0xca, 0xf5, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xa9, 0xb1, 0xd6, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9a, 0xa5, 0xce, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xcf, 0xc9, 0xc2, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x56, 0x5f, 0x89, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x41, 0x48, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x1a, 0x1b, 0x26, 0xff },
                    },
                },
            },
        },
        .{
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xf7, 0x76, 0x8e, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xff, 0x9e, 0x64, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xe0, 0xaf, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9e, 0xce, 0x6a, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x73, 0xda, 0xca, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xb4, 0xf9, 0xf8, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x2a, 0xc3, 0xde, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7d, 0xcf, 0xff, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x7a, 0xa2, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xbb, 0x9a, 0xf7, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xc0, 0xca, 0xf5, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xa9, 0xb1, 0xd6, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x9a, 0xa5, 0xce, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0xcf, 0xc9, 0xc2, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x56, 0x5f, 0x89, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x41, 0x48, 0x68, 0xff },
                    },
                },
            },
            .{
                .uint8 = .{
                    .sRGB = .{
                        .value = .{ 0x24, 0x28, 0x3b, 0xff },
                    },
                },
            },
        },
    };

    var display = phantom.display.Backend(.fbdev).Display.init(alloc, .compositor);
    defer display.deinit();
    std.debug.print("{}\n", .{display});

    const outputs = try @constCast(&display.display()).outputs();
    defer outputs.deinit();

    if (outputs.items.len == 0) {
        return error.NoOutputs;
    }

    const output = outputs.items[0];
    std.debug.print("{}\n", .{output});

    const surface = output.createSurface(.output, .{
        .size = (try output.info()).size.res,
    }) catch |e| @panic(@errorName(e));
    defer {
        surface.destroy() catch {};
        surface.deinit();
    }

    const scene = try surface.createScene(@enumFromInt(@intFromEnum(sceneBackendType)));
    std.debug.print("{}\n", .{scene});

    var children: [17]*phantom.scene.Node = undefined;

    for (&children, colors[0]) |*child, color| {
        child.* = try scene.createNode(.NodeRect, .{
            .color = color,
            .size = vizops.vector.Float32Vector2.init([_]f32{ 100.0 / 17.0, 100.0 }),
        });
    }

    const flex = try scene.createNode(.NodeFlex, .{
        .direction = .horizontal,
        .children = &children,
    });
    defer flex.deinit();

    while (true) {
        const seq = scene.seq;
        _ = try scene.frame(flex);
        if (seq != scene.seq) std.debug.print("Frame #{}\n", .{scene.seq});

        const currPalette = scene.seq % colors.len;
        for (children, colors[currPalette]) |child, color| {
            try child.setProperties(.{ .color = color });
        }
    }
}
