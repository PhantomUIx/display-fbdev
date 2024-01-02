const std = @import("std");
const vizops = @import("vizops");
const phantom = @import("phantom");
const Display = @import("display.zig");
const Surface = @import("surface.zig");
const types = @import("types.zig");
const Self = @This();

base: phantom.display.Output,
display: *Display,
file: std.fs.File,
surface: ?*Surface,
scale: vizops.vector.Float32Vector2,
name: []const u8,

pub fn new(display: *Display, file: std.fs.File) !*Self {
    const self = try display.allocator.create(Self);
    errdefer display.allocator.destroy(self);

    var fscreenInfo: types.FixScreenInfo = undefined;
    try fscreenInfo.get(file.handle);

    self.* = .{
        .base = .{
            .ptr = self,
            .vtable = &.{
                .surfaces = impl_surfaces,
                .createSurface = impl_create_surface,
                .info = impl_info,
                .updateInfo = impl_update_info,
                .deinit = impl_deinit,
            },
            .displayKind = display.kind,
            .type = @typeName(Self),
        },
        .display = display,
        .file = file,
        .surface = null,
        .scale = vizops.vector.Float32Vector2.init(1.0),
        .name = try display.allocator.dupe(u8, &fscreenInfo.id),
    };
    return self;
}

fn impl_surfaces(ctx: *anyopaque) anyerror!std.ArrayList(*phantom.display.Surface) {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var surfaces = std.ArrayList(*phantom.display.Surface).init(self.display.allocator);
    errdefer surfaces.deinit();

    if (self.surface) |surf| {
        try surfaces.append(&surf.base);
    }
    return surfaces;
}

fn impl_create_surface(ctx: *anyopaque, kind: phantom.display.Surface.Kind, _: phantom.display.Surface.Info) anyerror!*phantom.display.Surface {
    const self: *Self = @ptrCast(@alignCast(ctx));

    if (kind != .output) return error.InvalidKind;
    if (self.surface) |_| return error.AlreadyExists;

    self.surface = try Surface.new(self);
    return &self.surface.?.base;
}

fn impl_info(ctx: *anyopaque) anyerror!phantom.display.Output.Info {
    const self: *Self = @ptrCast(@alignCast(ctx));

    var fscreenInfo: types.FixScreenInfo = undefined;
    try fscreenInfo.get(self.file.handle);

    var vscreenInfo: types.VarScreenInfo = undefined;
    try vscreenInfo.get(self.file.handle);

    const res = vizops.vector.UsizeVector2.init([_]usize{
        vscreenInfo.xres,
        vscreenInfo.yres,
    });

    return .{
        .enable = true,
        .size = .{
            .phys = .{ .value = res.cast(f32).value },
            .res = .{ .value = res.value },
        },
        .scale = .{ .value = self.scale.value },
        .name = self.name,
        .manufacturer = self.name,
        .colorFormat = blk: {
            const hasAlpha = vscreenInfo.transp.len > 0;
            const isBgr = vscreenInfo.blue.offset < vscreenInfo.red.offset;
            const isAlphaFirst = vscreenInfo.transp.offset == 0;

            if (isBgr) {
                if (hasAlpha) {
                    if (isAlphaFirst) {
                        break :blk .{
                            .abgr = .{
                                @intCast(vscreenInfo.transp.len),
                                @intCast(vscreenInfo.blue.len),
                                @intCast(vscreenInfo.green.len),
                                @intCast(vscreenInfo.red.len),
                            },
                        };
                    }
                    break :blk .{
                        .bgra = .{
                            @intCast(vscreenInfo.blue.len),
                            @intCast(vscreenInfo.green.len),
                            @intCast(vscreenInfo.red.len),
                            @intCast(vscreenInfo.transp.len),
                        },
                    };
                }

                break :blk .{
                    .bgr = .{
                        @intCast(vscreenInfo.blue.len),
                        @intCast(vscreenInfo.green.len),
                        @intCast(vscreenInfo.red.len),
                    },
                };
            }

            if (hasAlpha) {
                if (isAlphaFirst) {
                    break :blk .{
                        .argb = .{
                            @intCast(vscreenInfo.transp.len),
                            @intCast(vscreenInfo.red.len),
                            @intCast(vscreenInfo.green.len),
                            @intCast(vscreenInfo.blue.len),
                        },
                    };
                }

                break :blk .{
                    .rgba = .{
                        @intCast(vscreenInfo.red.len),
                        @intCast(vscreenInfo.green.len),
                        @intCast(vscreenInfo.blue.len),
                        @intCast(vscreenInfo.transp.len),
                    },
                };
            }

            break :blk .{
                .rgb = .{
                    @intCast(vscreenInfo.red.len),
                    @intCast(vscreenInfo.green.len),
                    @intCast(vscreenInfo.blue.len),
                },
            };
        },
    };
}

fn impl_update_info(ctx: *anyopaque, info: phantom.display.Output.Info, fields: []std.meta.FieldEnum(phantom.display.Output.Info)) anyerror!void {
    const self: *Self = @ptrCast(@alignCast(ctx));

    var changeSize = false;
    var changeScale = false;
    var changeFormat = false;

    for (fields) |field| {
        switch (field) {
            .size => changeSize = true,
            .scale => changeScale = true,
            .colorFormat => changeFormat = true,
            else => return error.UnsupportedField,
        }
    }

    if (changeScale) self.scale.value = info.scale.value;
    return error.UnmatchedMode;
}

fn impl_deinit(ctx: *anyopaque) void {
    const self: *Self = @ptrCast(@alignCast(ctx));
    if (self.surface) |surface| surface.base.deinit();
    self.file.close();
    self.display.allocator.free(self.name);
    self.display.allocator.destroy(self);
}
