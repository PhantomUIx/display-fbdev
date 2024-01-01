const std = @import("std");

pub const Bitfield = extern struct {
    offset: u32,
    len: u32,
    msbRight: u32,
};

pub const VarScreenInfo = extern struct {
    xres: u32,
    yres: u32,
    xresVirtual: u32,
    yresVirtual: u32,
    xoffset: u32,
    yoffset: u32,
    bpp: u32,
    grayscale: u32,
    red: Bitfield,
    green: Bitfield,
    blue: Bitfield,
    transp: Bitfield,
    nonstd: u32,
    activate: u32,
    height: u32,
    width: u32,
    accelFlags: u32,
    pixclock: u32,
    leftMargin: u32,
    rightMargin: u32,
    upperMargin: u32,
    lowerMargin: u32,
    hsyncLen: u32,
    vsyncLen: u32,
    sync: u32,
    vmode: u32,
    rotate: u32,
    colorspace: u32,
    reserved: [4]u32,

    pub fn get(self: *VarScreenInfo, fd: std.os.linux.fd_t) !void {
        return switch (std.os.linux.getErrno(std.os.linux.ioctl(fd, 0x4600, @intFromPtr(self)))) {
            .SUCCESS => {},
            else => |e| std.os.unexpectedErrno(e),
        };
    }

    pub fn set(self: *const VarScreenInfo, fd: std.os.linux.fd_t) !void {
        return switch (std.os.linux.getErrno(std.os.linux.ioctl(fd, 0x4601, @intFromPtr(self)))) {
            .SUCCESS => {},
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};

pub const FixScreenInfo = extern struct {
    id: [16:0]u8,
    smemStart: usize,
    smemLen: u32,
    type: u32,
    typeAux: u32,
    visual: u32,
    xPanStep: u16,
    yPanStep: u16,
    yWrapStep: u16,
    lineLen: u32,
    mmioStart: usize,
    accel: u32,
    capabilities: u16,
    reserved: [2]u16,

    pub fn get(self: *FixScreenInfo, fd: std.os.linux.fd_t) !void {
        return switch (std.os.linux.getErrno(std.os.linux.ioctl(fd, 0x4602, @intFromPtr(self)))) {
            .SUCCESS => {},
            else => |e| std.os.unexpectedErrno(e),
        };
    }
};
