const std = @import("std");
const options = @import("zmesh_options");

pub fn init(alloc: std.mem.Allocator, io: std.Io) void {
    std.debug.assert(state == null);

    state = .{
        .io = io,
        .mem_allocator = alloc,
        .mem_allocations = .init(alloc),
    };
    state.?.mem_allocations.ensureTotalCapacity(32) catch unreachable;

    const zmeshMallocPtr = @extern(*?*const fn (size: usize) callconv(.c) ?*anyopaque, .{
        .name = "zmeshMallocPtr",
        .is_dll_import = options.shared,
    });
    const zmeshCallocPtr = @extern(*?*const fn (num: usize, size: usize) callconv(.c) ?*anyopaque, .{
        .name = "zmeshCallocPtr",
        .is_dll_import = options.shared,
    });
    const zmeshReallocPtr = @extern(*?*const fn (ptr: ?*anyopaque, size: usize) callconv(.c) ?*anyopaque, .{
        .name = "zmeshReallocPtr",
        .is_dll_import = options.shared,
    });
    const zmeshFreePtr = @extern(*?*const fn (maybe_ptr: ?*anyopaque) callconv(.c) void, .{
        .name = "zmeshFreePtr",
        .is_dll_import = options.shared,
    });

    zmeshMallocPtr.* = zmeshMalloc;
    zmeshCallocPtr.* = zmeshCalloc;
    zmeshReallocPtr.* = zmeshRealloc;
    zmeshFreePtr.* = zmeshFree;
    meshopt_setAllocator(zmeshMalloc, zmeshFree);
}

pub fn deinit() void {
    state.?.mem_allocations.deinit();
    state = null;
}

const MallocFn = *const fn (size: usize) callconv(.c) ?*anyopaque;
const FreeFn = *const fn (ptr: ?*anyopaque) callconv(.c) void;

extern fn meshopt_setAllocator(
    allocate: MallocFn,
    deallocate: FreeFn,
) void;

const mem_alignment: std.mem.Alignment = .@"16";
pub const GlobalState = struct {
    io: std.Io,
    mem_allocator: std.mem.Allocator,
    mem_allocations: std.AutoHashMap(usize, usize),
    mem_mutex: std.Io.Mutex = .init,
};
var state: ?GlobalState = null;

pub fn zmeshMalloc(size: usize) callconv(.c) ?*anyopaque {
    state.?.mem_mutex.lockUncancelable(state.?.io);
    defer state.?.mem_mutex.unlock(state.?.io);

    const mem = state.?.mem_allocator.alignedAlloc(
        u8,
        mem_alignment,
        size,
    ) catch @panic("zmesh: out of memory");

    state.?.mem_allocations.put(@intFromPtr(mem.ptr), size) catch @panic("zmesh: out of memory");
    return mem.ptr;
}

fn zmeshCalloc(num: usize, size: usize) callconv(.c) ?*anyopaque {
    const ptr = zmeshMalloc(num * size);
    if (ptr != null) {
        @memset(@as([*]u8, @ptrCast(ptr))[0 .. num * size], 0);
        return ptr;
    }
    return null;
}

pub fn zmeshAllocUser(user: ?*anyopaque, size: usize) callconv(.c) ?*anyopaque {
    _ = user;
    return zmeshMalloc(size);
}

fn zmeshRealloc(ptr: ?*anyopaque, size: usize) callconv(.c) ?*anyopaque {
    state.?.mem_mutex.lockUncancelable(state.?.io);
    defer state.?.mem_mutex.unlock(state.?.io);

    const old_size = if (ptr != null) state.?.mem_allocations.get(@intFromPtr(ptr.?)).? else 0;

    const old_mem = if (old_size > 0)
        @as([*]align(mem_alignment.toByteUnits()) u8, @ptrCast(@alignCast(ptr)))[0..old_size]
    else
        @as([*]align(mem_alignment.toByteUnits()) u8, undefined)[0..0];

    const mem = state.?.mem_allocator.realloc(old_mem, size) catch @panic("zmesh: out of memory");

    if (ptr != null) {
        const removed = state.?.mem_allocations.remove(@intFromPtr(ptr.?));
        std.debug.assert(removed);
    }

    state.?.mem_allocations.put(@intFromPtr(mem.ptr), size) catch @panic("zmesh: out of memory");

    return mem.ptr;
}

fn zmeshFree(maybe_ptr: ?*anyopaque) callconv(.c) void {
    if (maybe_ptr) |ptr| {
        state.?.mem_mutex.lockUncancelable(state.?.io);
        defer state.?.mem_mutex.unlock(state.?.io);

        const try_get_allocation = state.?.mem_allocations.fetchRemove(@intFromPtr(ptr));
        if (try_get_allocation) |alloc| {
            const size = alloc.value;
            const mem = @as([*]align(mem_alignment.toByteUnits()) u8, @ptrCast(@alignCast(ptr)))[0..size];
            state.?.mem_allocator.free(mem);
        }
    }
}

pub fn zmeshFreeUser(user: ?*anyopaque, ptr: ?*anyopaque) callconv(.c) void {
    _ = user;
    zmeshFree(ptr);
}
