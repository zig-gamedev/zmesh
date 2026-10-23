// For the documentation see: ../libs/meshoptimizer/meshoptimizer.h

const std = @import("std");
const assert = std.debug.assert;

pub const Stream = extern struct {
    data: *const anyopaque,
    size: usize,
    stride: usize,
};

// Indexing
pub inline fn generateVertexRemap(
    destination: []u32,
    indices: ?[]const u32,
    comptime T: type,
    vertices: []const T,
) usize {
    return meshopt_generateVertexRemap(
        destination.ptr,
        if (indices) |ind| ind.ptr else null,
        if (indices) |ind| ind.len else vertices.len,
        vertices.ptr,
        vertices.len,
        @sizeOf(T),
    );
}

pub inline fn generateVertexRemapMulti(
    destination: []u32,
    indices: ?[]const u32,
    index_count: usize,
    vertex_count: usize,
    streams: []const Stream,
) usize {
    return meshopt_generateVertexRemapMulti(
        destination.ptr,
        if (indices) |ind| ind.ptr else null,
        index_count,
        vertex_count,
        streams.ptr,
        streams.len,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn generateVertexRemapCustom(
    destination: []u32,
    indices: ?[]const u32,
    index_count: usize,
    comptime T: type,
    vertices: []const T,
    callback: *const fn (?*anyopaque, u32, u32) callconv(.C) c_int,
    context: ?*anyopaque,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_generateVertexRemapCustom(
        destination.ptr,
        if (indices) |ind| ind.ptr else null,
        index_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        callback,
        context,
    );
}

pub inline fn remapVertexBuffer(
    comptime T: type,
    destination: []T,
    vertices: []const T,
    remap: []const u32,
) void {
    meshopt_remapVertexBuffer(
        destination.ptr,
        vertices.ptr,
        vertices.len,
        @sizeOf(T),
        remap.ptr,
    );
}
pub inline fn remapIndexBuffer(
    destination: []u32,
    indices: ?[]const u32,
    remap: []const u32,
) void {
    meshopt_remapIndexBuffer(
        destination.ptr,
        if (indices) |ind| ind.ptr else null,
        if (indices) |ind| ind.len else remap.len,
        remap.ptr,
    );
}

/// `vertex_size` specifies how many leading bytes to compare for dedup
pub inline fn filterIndexBuffer(
    destination: []u32,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    vertex_size: usize,
) usize {
    return meshopt_filterIndexBuffer(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertices.ptr,
        vertices.len,
        vertex_size,
        @sizeOf(T),
    );
}

// Shadow/adjacency/tessellation/provoking index buffers
/// `T`: @sizeOf(T) bytes compared for shadow equivalence
pub inline fn generateShadowIndexBuffer(
    destination: []u32,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    vertex_stride: usize,
) void {
    meshopt_generateShadowIndexBuffer(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertices.ptr,
        vertices.len,
        @sizeOf(T),
        vertex_stride,
    );
}

pub inline fn generateShadowIndexBufferMulti(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
    streams: []const Stream,
) void {
    meshopt_generateShadowIndexBufferMulti(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
        streams.ptr,
        streams.len,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn generatePositionRemap(
    destination: []u32,
    comptime T: type,
    vertices: []const T,
) void {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    meshopt_generatePositionRemap(
        destination.ptr,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

pub inline fn generateAdjacencyIndexBuffer(
    destination: []u32,
    indices: []const u32,
    vertex_positions: []const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void {
    meshopt_generateAdjacencyIndexBuffer(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_positions.ptr,
        vertex_count,
        vertex_positions_stride,
    );
}

pub inline fn generateTessellationIndexBuffer(
    destination: []u32,
    indices: []const u32,
    vertex_positions: []const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void {
    meshopt_generateTessellationIndexBuffer(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_positions.ptr,
        vertex_count,
        vertex_positions_stride,
    );
}

pub inline fn generateProvokingIndexBuffer(
    destination: []u32,
    reorder: []u32,
    indices: []const u32,
    vertex_count: usize,
) usize {
    return meshopt_generateProvokingIndexBuffer(
        destination.ptr,
        reorder.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
    );
}

// Vertex cache optimization
pub inline fn optimizeVertexCache(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
) void {
    assert(destination.len >= indices.len);
    meshopt_optimizeVertexCache(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
    );
}

pub inline fn optimizeVertexCacheStrip(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
) void {
    assert(destination.len >= indices.len);
    meshopt_optimizeVertexCacheStrip(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
    );
}

pub inline fn optimizeVertexCacheFifo(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
    cache_size: u32,
) void {
    assert(destination.len >= indices.len);
    meshopt_optimizeVertexCacheFifo(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
        cache_size,
    );
}

// Overdraw optimization
/// `T`: first 12 bytes of T must be a float3 position
pub inline fn optimizeOverdraw(
    destination: []u32,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    threshold: f32,
) void {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    assert(destination.len >= indices.len);
    meshopt_optimizeOverdraw(
        destination.ptr,
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        threshold,
    );
}

// Vertex fetch optimization
pub inline fn optimizeVertexFetch(
    comptime T: type,
    destination: []T,
    indices: []u32,
    vertices: []const T,
) usize {
    assert(destination.len >= vertices.len);
    return meshopt_optimizeVertexFetch(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertices.ptr,
        vertices.len,
        @sizeOf(T),
    );
}

pub inline fn optimizeVertexFetchRemap(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
) usize {
    return meshopt_optimizeVertexFetchRemap(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
    );
}

// Simplifier
pub const SimplifyOptions = packed struct(u32) {
    lock_border: bool = false,
    sparse: bool = false,
    error_absolute: bool = false,
    prune: bool = false,
    regularize: bool = false,
    permissive: bool = false,
    regularize_light: bool = false,
    _pad: u25 = 0,
};

pub const SimplifyVertex = packed struct(u8) {
    lock: bool = false,
    protect: bool = false,
    priority: bool = false,
    _pad: u5 = 0,
};

pub const TangentOptions = packed struct(u32) {
    compatible: bool = false,
    zero_fallback: bool = false,
    _pad: u30 = 0,
};

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplify(
    destination: []u32,
    indices: []const u32,
    index_count: usize,
    comptime T: type,
    vertices: []const T,
    target_index_count: usize,
    target_error: f32,
    options: SimplifyOptions,
    out_result_error: ?*f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_simplify(
        destination.ptr,
        indices.ptr,
        index_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        target_index_count,
        target_error,
        @bitCast(options),
        if (out_result_error) |e| e else null,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifyWithAttributes(
    destination: []u32,
    indices: []const u32,
    index_count: usize,
    comptime T: type,
    vertices: []const T,
    comptime A: type,
    vertex_attributes: []const A,
    attribute_weights: []const f32,
    attribute_count: usize,
    vertex_lock: ?[]const u8,
    target_index_count: usize,
    target_error: f32,
    options: SimplifyOptions,
    out_result_error: ?*f32,
) usize {
    comptime {
        assert(@sizeOf(T) >= 12);
        assert(@sizeOf(T) % 4 == 0);
        assert(@sizeOf(A) % 4 == 0);
    }
    return meshopt_simplifyWithAttributes(
        destination.ptr,
        indices.ptr,
        index_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        @ptrCast(vertex_attributes.ptr),
        @sizeOf(A),
        attribute_weights.ptr,
        attribute_count,
        if (vertex_lock) |vl| vl.ptr else null,
        target_index_count,
        target_error,
        @bitCast(options),
        if (out_result_error) |e| e else null,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifyWithUpdate(
    indices: []u32,
    index_count: usize,
    comptime T: type,
    vertex_positions: []T,
    comptime A: type,
    vertex_attributes: []A,
    attribute_weights: []const f32,
    attribute_count: usize,
    vertex_lock: ?[]const u8,
    target_index_count: usize,
    target_error: f32,
    options: SimplifyOptions,
    out_result_error: ?*f32,
) usize {
    comptime {
        assert(@sizeOf(T) >= 12);
        assert(@sizeOf(T) % 4 == 0);
        assert(@sizeOf(A) % 4 == 0);
    }
    return meshopt_simplifyWithUpdate(
        indices.ptr,
        index_count,
        @ptrCast(vertex_positions.ptr),
        vertex_positions.len,
        @sizeOf(T),
        @ptrCast(vertex_attributes.ptr),
        @sizeOf(A),
        attribute_weights.ptr,
        attribute_count,
        if (vertex_lock) |vl| vl.ptr else null,
        target_index_count,
        target_error,
        @bitCast(options),
        if (out_result_error) |e| e else null,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifySloppy(
    destination: []u32,
    indices: []const u32,
    index_count: usize,
    comptime T: type,
    vertices: []const T,
    vertex_lock: ?[]const u8,
    target_index_count: usize,
    target_error: f32,
    out_result_error: ?*f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_simplifySloppy(
        destination.ptr,
        indices.ptr,
        index_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        if (vertex_lock) |vl| vl.ptr else null,
        target_index_count,
        target_error,
        if (out_result_error) |e| e else null,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifyPrune(
    destination: []u32,
    indices: []const u32,
    index_count: usize,
    comptime T: type,
    vertices: []const T,
    target_error: f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_simplifyPrune(
        destination.ptr,
        indices.ptr,
        index_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        target_error,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifyPoints(
    destination: []u32,
    comptime T: type,
    vertex_positions: []const T,
    vertex_colors: ?[]const f32,
    vertex_colors_stride: usize,
    color_weight: f32,
    target_vertex_count: usize,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_simplifyPoints(
        destination.ptr,
        @ptrCast(vertex_positions.ptr),
        vertex_positions.len,
        @sizeOf(T),
        if (vertex_colors) |vc| vc.ptr else null,
        vertex_colors_stride,
        color_weight,
        target_vertex_count,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn simplifyScale(
    comptime T: type,
    vertices: []const T,
) f32 {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_simplifyScale(
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

// Stripification
pub inline fn stripify(
    destination: []u32,
    indices: []const u32,
    vertex_count: usize,
    restart_index: u32,
) usize {
    return meshopt_stripify(
        destination.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
        restart_index,
    );
}

pub inline fn stripifyBound(index_count: usize) usize {
    return meshopt_stripifyBound(index_count);
}

pub inline fn unstripify(
    destination: []u32,
    indices: []const u32,
    restart_index: u32,
) usize {
    return meshopt_unstripify(
        destination.ptr,
        indices.ptr,
        indices.len,
        restart_index,
    );
}

pub inline fn unstripifyBound(index_count: usize) usize {
    return meshopt_unstripifyBound(index_count);
}

// Statistics
pub const VertexCacheStatistics = extern struct {
    vertices_transformed: u32,
    warps_executed: u32,
    acmr: f32,
    atvr: f32,
};

pub const VertexFetchStatistics = extern struct {
    bytes_fetched: u32,
    overfetch: f32,
};

pub const OverdrawStatistics = extern struct {
    pixels_covered: u32,
    pixels_shaded: u32,
    overdraw: f32,
};

pub const CoverageStatistics = extern struct {
    coverage: [3]f32,
    extent: f32,
};

pub inline fn analyzeVertexCache(
    indices: []const u32,
    vertex_count: usize,
    cache_size: u32,
    warp_size: u32,
    primgroup_size: u32,
) VertexCacheStatistics {
    return meshopt_analyzeVertexCache(
        indices.ptr,
        indices.len,
        vertex_count,
        cache_size,
        warp_size,
        primgroup_size,
    );
}

pub inline fn analyzeVertexFetch(
    indices: []const u32,
    vertex_count: usize,
    vertex_size: usize,
) VertexFetchStatistics {
    return meshopt_analyzeVertexFetch(indices.ptr, indices.len, vertex_count, vertex_size);
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn analyzeOverdraw(
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
) OverdrawStatistics {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_analyzeOverdraw(indices.ptr, indices.len, @ptrCast(vertices.ptr), vertices.len, @sizeOf(T));
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn analyzeCoverage(
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
) CoverageStatistics {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_analyzeCoverage(indices.ptr, indices.len, @ptrCast(vertices.ptr), vertices.len, @sizeOf(T));
}

// Mesh shading
pub const Meshlet = extern struct {
    vertex_offset: u32,
    triangle_offset: u32,
    vertex_count: u32,
    triangle_count: u32,
};

pub inline fn buildMeshletsBound(index_count: usize, max_vertices: usize, max_triangles: usize) usize {
    return meshopt_buildMeshletsBound(index_count, max_vertices, max_triangles);
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn buildMeshlets(
    meshlets: []Meshlet,
    meshlet_vertices: []u32,
    meshlet_triangles: []u8,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    max_vertices: usize,
    max_triangles: usize,
    cone_weight: f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_buildMeshlets(
        meshlets.ptr,
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        max_vertices,
        max_triangles,
        cone_weight,
    );
}

pub inline fn buildMeshletsScan(
    meshlets: []Meshlet,
    meshlet_vertices: []u32,
    meshlet_triangles: []u8,
    indices: []const u32,
    vertex_count: usize,
    max_vertices: usize,
    max_triangles: usize,
) usize {
    return meshopt_buildMeshletsScan(
        meshlets.ptr,
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        indices.ptr,
        indices.len,
        vertex_count,
        max_vertices,
        max_triangles,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn buildMeshletsFlex(
    meshlets: []Meshlet,
    meshlet_vertices: []u32,
    meshlet_triangles: []u8,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    max_vertices: usize,
    min_triangles: usize,
    max_triangles: usize,
    cone_weight: f32,
    split_factor: f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_buildMeshletsFlex(
        meshlets.ptr,
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        max_vertices,
        min_triangles,
        max_triangles,
        cone_weight,
        split_factor,
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn buildMeshletsSpatial(
    meshlets: []Meshlet,
    meshlet_vertices: []u32,
    meshlet_triangles: []u8,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
    max_vertices: usize,
    min_triangles: usize,
    max_triangles: usize,
    fill_weight: f32,
) usize {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_buildMeshletsSpatial(
        meshlets.ptr,
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        max_vertices,
        min_triangles,
        max_triangles,
        fill_weight,
    );
}

pub inline fn optimizeMeshlet(
    meshlet_vertices: []u32,
    meshlet_triangles: []u8,
    triangle_count: usize,
    vertex_count: usize,
) void {
    meshopt_optimizeMeshlet(
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        triangle_count,
        vertex_count,
    );
}

pub inline fn optimizeMeshletLevel(
    meshlet_vertices: []u32,
    vertex_count: usize,
    meshlet_triangles: []u8,
    triangle_count: usize,
    level: i32,
) void {
    meshopt_optimizeMeshletLevel(
        meshlet_vertices.ptr,
        vertex_count,
        meshlet_triangles.ptr,
        triangle_count,
        level,
    );
}

// Bounds
pub const SphereBounds = extern struct {
    center: [3]f32,
    radius: f32,
};

pub const Bounds = extern struct {
    center: [3]f32,
    radius: f32,
    cone_apex: [3]f32,
    cone_axis: [3]f32,
    cone_cutoff: f32,
    cone_axis_s8: [3]i8,
    cone_cutoff_s8: i8,
};

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn computeClusterBounds(
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
) Bounds {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_computeClusterBounds(
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn computeMeshletBounds(
    meshlet_vertices: []const u32,
    meshlet_triangles: []const u8,
    triangle_count: usize,
    comptime T: type,
    vertices: []const T,
) Bounds {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    return meshopt_computeMeshletBounds(
        meshlet_vertices.ptr,
        meshlet_triangles.ptr,
        triangle_count,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn computeSphereBounds(
    comptime T: type,
    positions: []const T,
    radii: ?[]const f32,
    radii_stride: usize,
) SphereBounds {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    const b = meshopt_computeSphereBounds(
        @ptrCast(positions.ptr),
        positions.len,
        @sizeOf(T),
        if (radii) |r| r.ptr else null,
        radii_stride,
    );
    return .{ .center = b.center, .radius = b.radius };
}

pub inline fn extractMeshletIndices(
    vertices: []u32,
    triangles: []u8,
    indices: []const u32,
) usize {
    return meshopt_extractMeshletIndices(
        vertices.ptr,
        triangles.ptr,
        indices.ptr,
        indices.len,
    );
}

// Partition
pub inline fn partitionClusters(
    destination: []u32,
    cluster_indices: []const u32,
    cluster_index_counts: []const u32,
    vertex_positions: ?[]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    target_partition_size: usize,
) usize {
    return meshopt_partitionClusters(
        destination.ptr,
        cluster_indices.ptr,
        cluster_indices.len,
        cluster_index_counts.ptr,
        cluster_index_counts.len,
        if (vertex_positions) |vp| vp.ptr else null,
        vertex_count,
        vertex_positions_stride,
        target_partition_size,
    );
}

// Spatial sorting
/// `T`: first 12 bytes of T must be a float3 position
pub inline fn spatialSortRemap(
    destination: []u32,
    comptime T: type,
    vertices: []const T,
) void {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    meshopt_spatialSortRemap(
        destination.ptr,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn spatialSortTriangles(
    destination: []u32,
    indices: []const u32,
    comptime T: type,
    vertices: []const T,
) void {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    meshopt_spatialSortTriangles(
        destination.ptr,
        indices.ptr,
        indices.len,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
    );
}

/// `T`: first 12 bytes of T must be a float3 position
pub inline fn spatialClusterPoints(
    destination: []u32,
    comptime T: type,
    vertices: []const T,
    cluster_size: usize,
) void {
    comptime { assert(@sizeOf(T) >= 12); assert(@sizeOf(T) % 4 == 0); }
    meshopt_spatialClusterPoints(
        destination.ptr,
        @ptrCast(vertices.ptr),
        vertices.len,
        @sizeOf(T),
        cluster_size,
    );
}

// Tangents
/// `T`: first 12 bytes of T must be a float3 position
/// `N`: first 12 bytes of N must be a float3 normal
/// `U`: first 8 bytes of U must be a float2 UV
pub inline fn generateTangents(
    result: []f32,
    indices: ?[]const u32,
    comptime T: type,
    vertex_positions: []const T,
    comptime N: type,
    vertex_normals: []const N,
    comptime U: type,
    vertex_uvs: []const U,
    options: TangentOptions,
) void {
    comptime {
        assert(@sizeOf(T) >= 12);
        assert(@sizeOf(T) % 4 == 0);
        assert(@sizeOf(N) >= 12);
        assert(@sizeOf(N) % 4 == 0);
        assert(@sizeOf(U) >= 8);
        assert(@sizeOf(U) % 4 == 0);
    }
    const index_count = if (indices) |ind| ind.len else vertex_positions.len;
    meshopt_generateTangents(
        result.ptr,
        if (indices) |ind| ind.ptr else null,
        index_count,
        @ptrCast(vertex_positions.ptr),
        vertex_positions.len,
        @sizeOf(T),
        @ptrCast(vertex_normals.ptr),
        @sizeOf(N),
        @ptrCast(vertex_uvs.ptr),
        @sizeOf(U),
        @bitCast(options),
    );
}

// Index buffer encoding/decoding
pub inline fn encodeIndexBuffer(
    buffer: []u8,
    indices: []const u32,
) usize {
    return meshopt_encodeIndexBuffer(
        buffer.ptr,
        buffer.len,
        indices.ptr,
        indices.len,
    );
}

pub inline fn encodeIndexBufferBound(index_count: usize, vertex_count: usize) usize {
    return meshopt_encodeIndexBufferBound(index_count, vertex_count);
}

pub inline fn encodeIndexVersion(version: i32) void {
    meshopt_encodeIndexVersion(version);
}

/// comptime T: must be u16 or u32
pub inline fn decodeIndexBuffer(
    comptime T: type,
    destination: []T,
    buffer: []const u8,
) i32 {
    return meshopt_decodeIndexBuffer(
        destination.ptr,
        destination.len,
        @sizeOf(T),
        buffer.ptr,
        buffer.len,
    );
}

pub inline fn decodeIndexVersion(buffer: []const u8) i32 {
    return meshopt_decodeIndexVersion(buffer.ptr, buffer.len);
}

// Index sequence encoding/decoding
pub inline fn encodeIndexSequence(
    buffer: []u8,
    indices: []const u32,
) usize {
    return meshopt_encodeIndexSequence(
        buffer.ptr,
        buffer.len,
        indices.ptr,
        indices.len,
    );
}

pub inline fn encodeIndexSequenceBound(index_count: usize, vertex_count: usize) usize {
    return meshopt_encodeIndexSequenceBound(index_count, vertex_count);
}

/// `T`: must be u16 or u32
pub inline fn decodeIndexSequence(
    comptime T: type,
    destination: []T,
    buffer: []const u8,
) i32 {
    return meshopt_decodeIndexSequence(
        destination.ptr,
        destination.len,
        @sizeOf(T),
        buffer.ptr,
        buffer.len,
    );
}

// Meshlet encoding/decoding
pub inline fn encodeMeshlet(
    buffer: []u8,
    vertices: ?[]const u32,
    triangles: []const u8,
) usize {
    return meshopt_encodeMeshlet(
        buffer.ptr,
        buffer.len,
        if (vertices) |v| v.ptr else null,
        if (vertices) |v| v.len else 0,
        triangles.ptr,
        triangles.len,
    );
}

pub inline fn encodeMeshletBound(max_vertices: usize, max_triangles: usize) usize {
    return meshopt_encodeMeshletBound(max_vertices, max_triangles);
}

pub inline fn decodeMeshlet(
    vertices: []u32,
    vertex_size: usize,
    triangles: []u8,
    triangle_size: usize,
    buffer: []const u8,
) i32 {
    return meshopt_decodeMeshlet(
        vertices.ptr,
        vertices.len,
        vertex_size,
        triangles.ptr,
        triangles.len,
        triangle_size,
        buffer.ptr,
        buffer.len,
    );
}

// Vertex buffer encoding/decoding
pub inline fn encodeVertexBuffer(
    buffer: []u8,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
) usize {
    return meshopt_encodeVertexBuffer(
        buffer.ptr,
        buffer.len,
        vertices,
        vertex_count,
        vertex_size,
    );
}

pub inline fn encodeVertexBufferBound(vertex_count: usize, vertex_size: usize) usize {
    return meshopt_encodeVertexBufferBound(vertex_count, vertex_size);
}

pub inline fn encodeVertexBufferLevel(
    buffer: []u8,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    level: i32,
    version: i32,
) usize {
    return meshopt_encodeVertexBufferLevel(
        buffer.ptr,
        buffer.len,
        vertices,
        vertex_count,
        vertex_size,
        level,
        version,
    );
}

pub inline fn encodeVertexVersion(version: i32) void {
    meshopt_encodeVertexVersion(version);
}

pub inline fn decodeVertexBuffer(
    destination: *anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    buffer: []const u8,
) i32 {
    return meshopt_decodeVertexBuffer(
        destination,
        vertex_count,
        vertex_size,
        buffer.ptr,
        buffer.len,
    );
}

pub inline fn decodeVertexVersion(buffer: []const u8) i32 {
    return meshopt_decodeVertexVersion(buffer.ptr, buffer.len);
}

// Vertex buffer filters
pub inline fn decodeFilterOct(buffer: *anyopaque, count: usize, stride: usize) void {
    meshopt_decodeFilterOct(buffer, count, stride);
}

pub inline fn decodeFilterQuat(buffer: *anyopaque, count: usize, stride: usize) void {
    meshopt_decodeFilterQuat(buffer, count, stride);
}

pub inline fn decodeFilterExp(buffer: *anyopaque, count: usize, stride: usize) void {
    meshopt_decodeFilterExp(buffer, count, stride);
}

pub inline fn decodeFilterColor(buffer: *anyopaque, count: usize, stride: usize) void {
    meshopt_decodeFilterColor(buffer, count, stride);
}

// Vertex buffer filter encoders
pub const EncodeExpMode = enum(c_int) {
    separate,
    shared_vector,
    shared_component,
    clamped,
};

pub inline fn encodeFilterOct(destination: *anyopaque, count: usize, stride: usize, bits: i32, data: []const f32) void {
    meshopt_encodeFilterOct(destination, count, stride, bits, data.ptr);
}

pub inline fn encodeFilterQuat(destination: *anyopaque, count: usize, stride: usize, bits: i32, data: []const f32) void {
    meshopt_encodeFilterQuat(destination, count, stride, bits, data.ptr);
}

pub inline fn encodeFilterExp(destination: *anyopaque, count: usize, stride: usize, bits: i32, data: []const f32, mode: EncodeExpMode) void {
    meshopt_encodeFilterExp(destination, count, stride, bits, data.ptr, mode);
}

pub inline fn encodeFilterColor(destination: *anyopaque, count: usize, stride: usize, bits: i32, data: []const f32) void {
    meshopt_encodeFilterColor(destination, count, stride, bits, data.ptr);
}

// Quantization
pub inline fn quantizeHalf(v: f32) u16 {
    return meshopt_quantizeHalf(v);
}

pub inline fn quantizeFloat(v: f32, n: i32) f32 {
    return meshopt_quantizeFloat(v, n);
}

pub inline fn dequantizeHalf(h: u16) f32 {
    return meshopt_dequantizeHalf(h);
}

// Extern declarations
extern fn meshopt_generateVertexRemap(
    destination: [*]u32,
    indices: ?[*]const u32,
    index_count: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
) usize;
extern fn meshopt_generateVertexRemapMulti(
    destination: [*]u32,
    indices: ?[*]const u32,
    index_count: usize,
    vertex_count: usize,
    streams: [*]const Stream,
    stream_count: usize,
) usize;
extern fn meshopt_generateVertexRemapCustom(
    destination: [*]u32,
    indices: ?[*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    callback: *const fn (?*anyopaque, u32, u32) callconv(.C) c_int,
    context: ?*anyopaque,
) usize;
extern fn meshopt_remapVertexBuffer(
    destination: *anyopaque,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    remap: [*]const u32,
) void;
extern fn meshopt_remapIndexBuffer(
    destination: [*]u32,
    indices: ?[*]const u32,
    index_count: usize,
    remap: [*]const u32,
) void;
extern fn meshopt_filterIndexBuffer(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    vertex_stride: usize,
) usize;
extern fn meshopt_generateShadowIndexBuffer(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    vertex_stride: usize,
) void;
extern fn meshopt_generateShadowIndexBufferMulti(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    streams: [*]const Stream,
    stream_count: usize,
) void;
extern fn meshopt_generatePositionRemap(
    destination: [*]u32,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void;
extern fn meshopt_generateAdjacencyIndexBuffer(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void;
extern fn meshopt_generateTessellationIndexBuffer(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void;
extern fn meshopt_generateProvokingIndexBuffer(
    destination: [*]u32,
    reorder: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
) usize;
extern fn meshopt_optimizeVertexCache(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
) void;
extern fn meshopt_optimizeVertexCacheStrip(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
) void;
extern fn meshopt_optimizeVertexCacheFifo(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    cache_size: u32,
) void;
extern fn meshopt_optimizeOverdraw(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    threshold: f32,
) void;
extern fn meshopt_optimizeVertexFetch(
    destination: *anyopaque,
    indices: [*]u32,
    index_count: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
) usize;
extern fn meshopt_optimizeVertexFetchRemap(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
) usize;
extern fn meshopt_simplify(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    target_index_count: usize,
    target_error: f32,
    options: u32,
    out_result_error: ?*f32,
) usize;
extern fn meshopt_simplifyWithAttributes(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    vertex_attributes: [*]const f32,
    vertex_attributes_stride: usize,
    attribute_weights: [*]const f32,
    attribute_count: usize,
    vertex_lock: ?[*]const u8,
    target_index_count: usize,
    target_error: f32,
    options: u32,
    out_result_error: ?*f32,
) usize;
extern fn meshopt_simplifySloppy(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    vertex_lock: ?[*]const u8,
    target_index_count: usize,
    target_error: f32,
    out_result_error: ?*f32,
) usize;
extern fn meshopt_simplifyPrune(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    target_error: f32,
) usize;
extern fn meshopt_simplifyPoints(
    destination: [*]u32,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    vertex_colors: ?[*]const f32,
    vertex_colors_stride: usize,
    color_weight: f32,
    target_vertex_count: usize,
) usize;
extern fn meshopt_simplifyScale(
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) f32;
extern fn meshopt_simplifyWithUpdate(
    indices: [*]u32,
    index_count: usize,
    vertex_positions: [*]f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    vertex_attributes: [*]f32,
    vertex_attributes_stride: usize,
    attribute_weights: [*]const f32,
    attribute_count: usize,
    vertex_lock: ?[*]const u8,
    target_index_count: usize,
    target_error: f32,
    options: u32,
    out_result_error: ?*f32,
) usize;
extern fn meshopt_stripify(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    restart_index: u32,
) usize;
extern fn meshopt_stripifyBound(
    index_count: usize,
) usize;
extern fn meshopt_unstripify(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    restart_index: u32,
) usize;
extern fn meshopt_unstripifyBound(
    index_count: usize,
) usize;
extern fn meshopt_analyzeVertexCache(
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    cache_size: u32,
    warp_size: u32,
    primgroup_size: u32,
) VertexCacheStatistics;
extern fn meshopt_analyzeVertexFetch(
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    vertex_size: usize,
) VertexFetchStatistics;
extern fn meshopt_analyzeOverdraw(
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) OverdrawStatistics;
extern fn meshopt_analyzeCoverage(
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) CoverageStatistics;
extern fn meshopt_buildMeshletsBound(
    index_count: usize,
    max_vertices: usize,
    max_triangles: usize,
) usize;
extern fn meshopt_buildMeshlets(
    meshlets: [*]Meshlet,
    meshlet_vertices: [*]u32,
    meshlet_triangles: [*]u8,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    max_vertices: usize,
    max_triangles: usize,
    cone_weight: f32,
) usize;
extern fn meshopt_buildMeshletsScan(
    meshlets: [*]Meshlet,
    meshlet_vertices: [*]u32,
    meshlet_triangles: [*]u8,
    indices: [*]const u32,
    index_count: usize,
    vertex_count: usize,
    max_vertices: usize,
    max_triangles: usize,
) usize;
extern fn meshopt_buildMeshletsFlex(
    meshlets: [*]Meshlet,
    meshlet_vertices: [*]u32,
    meshlet_triangles: [*]u8,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    max_vertices: usize,
    min_triangles: usize,
    max_triangles: usize,
    cone_weight: f32,
    split_factor: f32,
) usize;
extern fn meshopt_buildMeshletsSpatial(
    meshlets: [*]Meshlet,
    meshlet_vertices: [*]u32,
    meshlet_triangles: [*]u8,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    max_vertices: usize,
    min_triangles: usize,
    max_triangles: usize,
    fill_weight: f32,
) usize;
extern fn meshopt_optimizeMeshlet(
    meshlet_vertices: [*]u32,
    meshlet_triangles: [*]u8,
    triangle_count: usize,
    vertex_count: usize,
) void;
extern fn meshopt_optimizeMeshletLevel(
    meshlet_vertices: [*]u32,
    vertex_count: usize,
    meshlet_triangles: [*]u8,
    triangle_count: usize,
    level: i32,
) void;
extern fn meshopt_computeClusterBounds(
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) Bounds;
extern fn meshopt_computeMeshletBounds(
    meshlet_vertices: [*]const u32,
    meshlet_triangles: [*]const u8,
    triangle_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) Bounds;
extern fn meshopt_computeSphereBounds(
    positions: [*]const f32,
    count: usize,
    positions_stride: usize,
    radii: ?[*]const f32,
    radii_stride: usize,
) Bounds;
extern fn meshopt_extractMeshletIndices(
    vertices: [*]u32,
    triangles: [*]u8,
    indices: [*]const u32,
    index_count: usize,
) usize;
extern fn meshopt_partitionClusters(
    destination: [*]u32,
    cluster_indices: [*]const u32,
    total_index_count: usize,
    cluster_index_counts: [*]const u32,
    cluster_count: usize,
    vertex_positions: ?[*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    target_partition_size: usize,
) usize;
extern fn meshopt_spatialSortRemap(
    destination: [*]u32,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void;
extern fn meshopt_spatialSortTriangles(
    destination: [*]u32,
    indices: [*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
) void;
extern fn meshopt_spatialClusterPoints(
    destination: [*]u32,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    cluster_size: usize,
) void;
extern fn meshopt_generateTangents(
    result: [*]f32,
    indices: ?[*]const u32,
    index_count: usize,
    vertex_positions: [*]const f32,
    vertex_count: usize,
    vertex_positions_stride: usize,
    vertex_normals: [*]const f32,
    vertex_normals_stride: usize,
    vertex_uvs: [*]const f32,
    vertex_uvs_stride: usize,
    options: u32,
) void;
extern fn meshopt_encodeIndexBuffer(
    buffer: [*]u8,
    buffer_size: usize,
    indices: [*]const u32,
    index_count: usize,
) usize;
extern fn meshopt_encodeIndexBufferBound(
    index_count: usize,
    vertex_count: usize,
) usize;
extern fn meshopt_encodeIndexVersion(
    version: i32,
) void;
extern fn meshopt_decodeIndexBuffer(
    destination: *anyopaque,
    index_count: usize,
    index_size: usize,
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_decodeIndexVersion(
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_encodeIndexSequence(
    buffer: [*]u8,
    buffer_size: usize,
    indices: [*]const u32,
    index_count: usize,
) usize;
extern fn meshopt_encodeIndexSequenceBound(
    index_count: usize,
    vertex_count: usize,
) usize;
extern fn meshopt_decodeIndexSequence(
    destination: *anyopaque,
    index_count: usize,
    index_size: usize,
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_encodeMeshlet(
    buffer: [*]u8,
    buffer_size: usize,
    vertices: ?[*]const u32,
    vertex_count: usize,
    triangles: [*]const u8,
    triangle_count: usize,
) usize;
extern fn meshopt_encodeMeshletBound(
    max_vertices: usize,
    max_triangles: usize,
) usize;
extern fn meshopt_decodeMeshlet(
    vertices: *anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    triangles: *anyopaque,
    triangle_count: usize,
    triangle_size: usize,
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_encodeVertexBuffer(
    buffer: [*]u8,
    buffer_size: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
) usize;
extern fn meshopt_encodeVertexBufferBound(
    vertex_count: usize,
    vertex_size: usize,
) usize;
extern fn meshopt_encodeVertexBufferLevel(
    buffer: [*]u8,
    buffer_size: usize,
    vertices: *const anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    level: i32,
    version: i32,
) usize;
extern fn meshopt_encodeVertexVersion(
    version: i32,
) void;
extern fn meshopt_decodeVertexBuffer(
    destination: *anyopaque,
    vertex_count: usize,
    vertex_size: usize,
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_decodeVertexVersion(
    buffer: [*]const u8,
    buffer_size: usize,
) i32;
extern fn meshopt_decodeFilterOct(
    buffer: *anyopaque,
    count: usize,
    stride: usize,
) void;
extern fn meshopt_decodeFilterQuat(
    buffer: *anyopaque,
    count: usize,
    stride: usize,
) void;
extern fn meshopt_decodeFilterExp(
    buffer: *anyopaque,
    count: usize,
    stride: usize,
) void;
extern fn meshopt_decodeFilterColor(
    buffer: *anyopaque,
    count: usize,
    stride: usize,
) void;
extern fn meshopt_encodeFilterOct(
    destination: *anyopaque,
    count: usize,
    stride: usize,
    bits: i32,
    data: [*]const f32,
) void;
extern fn meshopt_encodeFilterQuat(
    destination: *anyopaque,
    count: usize,
    stride: usize,
    bits: i32,
    data: [*]const f32,
) void;
extern fn meshopt_encodeFilterExp(
    destination: *anyopaque,
    count: usize,
    stride: usize,
    bits: i32,
    data: [*]const f32,
    mode: EncodeExpMode,
) void;
extern fn meshopt_encodeFilterColor(
    destination: *anyopaque,
    count: usize,
    stride: usize,
    bits: i32,
    data: [*]const f32,
) void;
extern fn meshopt_quantizeHalf(
    v: f32,
) u16;
extern fn meshopt_quantizeFloat(
    v: f32,
    n: i32,
) f32;
extern fn meshopt_dequantizeHalf(
    h: u16,
) f32;
