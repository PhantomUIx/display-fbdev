const std = @import("std");
const Allocator = std.mem.Allocator;
const phantom = @import("phantom");
const Output = @import("output.zig");
const Self = @This();

allocator: Allocator,
kind: phantom.display.Base.Kind,

pub fn init(alloc: Allocator, kind: phantom.display.Base.Kind) Self {
    return .{
        .allocator = alloc,
        .kind = kind,
    };
}

pub fn deinit(self: *Self) void {
    _ = self;
}

pub fn display(self: *Self) phantom.display.Base {
    return .{
        .vtable = &.{
            .outputs = impl_outputs,
        },
        .type = @typeName(Self),
        .ptr = self,
        .kind = self.kind,
    };
}

fn impl_outputs(ctx: *anyopaque) anyerror!std.ArrayList(*phantom.display.Output) {
    const self: *Self = @ptrCast(@alignCast(ctx));
    var outputs = std.ArrayList(*phantom.display.Output).init(self.allocator);
    errdefer outputs.deinit();

    var dir = try std.fs.openDirAbsolute("/dev", .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (entry.kind != .character_device) continue;
        if (!std.mem.startsWith(u8, entry.name, "fb")) continue;

        var file = try dir.openFile(entry.name, .{ .mode = .read_write });
        errdefer file.close();

        const output = try Output.new(self, file);
        errdefer output.base.deinit();
        try outputs.append(&output.base);
    }
    return outputs;
}
