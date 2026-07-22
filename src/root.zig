const std = @import("std");

pub const Shape = @import("Shape.zig");
pub const io = @import("io.zig");
pub const opt = @import("zmeshoptimizer.zig");
pub const mem = @import("memory.zig");

pub fn init(alloc: std.mem.Allocator, io_impl: std.Io) void {
    mem.init(alloc, io_impl);
}

pub fn deinit() void {
    mem.deinit();
}

test {
    std.testing.refAllDecls(@This());
}
