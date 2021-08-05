const std = @import("std");

pub const c = @cImport(@cInclude("TracyC.h"));
pub const enable = !std.builtin.is_test and @import("build_options").tracy_enable;
pub const ZoneContext = c.TracyCZoneCtx;

const depth = 1;

pub const Zone = struct {
    usingnamespace if (!enable) struct {} else
        struct { context: ZoneContext, };

    pub inline fn end(zone: Zone) void {
        if (enable)
            c.___tracy_emit_zone_end(zone.context);
    }

    pub inline fn text(zone: Zone, text_: []const u8) void {
        if (enable)
            c.___tracy_emit_zone_text(zone.context, text_.ptr, text_.len);
    }

    pub inline fn name(zone: Zone, name_: []const u8) void {
        if (enable)
            c.___tracy_emit_zone_name(zone.context, name_.ptr, name_.len);
    }

    pub inline fn color(zone: Zone, color_: u32) void {
        if (enable)
            c.___tracy_emit_zone_color(zone.context, color_);
    }
};

pub inline fn startZone(src: std.builtin.SourceLocation) Zone {
    if (enable) {
        const name = null;
        const color = 0;
        const zone_info = ZoneInfo.init(src, name, color);
        const active = @boolToInt(true); // Always enable the zone.
        const context = c.___tracy_emit_zone_begin_callstack(&zone_info, depth, active);
        return .{ .context = context };
    } else {
        return .{};
    }
}

/// Corresponds to `___tracy_source_location_data`.
pub const ZoneInfo = extern struct {
    name: ?[*:0]const u8,
    function: [*:0]const u8,
    file: [*:0]const u8,
    line: u32,
    color: u32,

    pub inline fn init(src: std.builtin.SourceLocation, name: [*:0]const u8, color: u32) ZoneInfo {
        return .{
            .name = name,
            .function = src.fn_name,
            .file = src.file,
            .line = src.line,
            .color = color,
        };
    }
};

comptime {
    if (enable)
        std.debug.assert(@sizeOf(ZoneInfo) ==
                         @sizeOf(c.___tracy_source_location_data));
}

pub inline fn setThreadName(name: [*:0]const u8) void {
    if (enable)
        setThreadNameAlways(name);
}
/// Note that this is not disabled when tracy is disabled!
pub inline fn setThreadNameAlways(name: [*:0]const u8) void {
    c.___tracy_set_thread_name(name);
}

pub inline fn logAlloc(memory: []const u8) void {
    if (enable)
        c.___tracy_emit_memory_alloc_callstack(memory.ptr, memory.len, depth, @boolToInt(false));
}
pub inline fn logFree(memory: []const u8) void {
    if (enable)
        c.___tracy_emit_memory_free_callstack(memory.ptr, memory.len, depth, @boolToInt(false));
}
pub inline fn logAllocNamed(memory: []const u8, name: [*:0]const u8) void {
    if (enable)
        c.___tracy_emit_memory_alloc_callstack_named(memory.ptr, memory.len, depth, @boolToInt(false), name);
}
pub inline fn logFreeNamed(memory: []const u8, name: [*:0]const u8) void {
    if (enable)
        c.___tracy_emit_memory_free_callstack_named(memory.ptr, memory.len, depth, @boolToInt(false), name);
}

pub inline fn messageDynamic(text: []const u8) void {
    if (enable)
        c.___tracy_emit_message(text.ptr, text.len, @boolToInt(true));
}
pub inline fn messageStatic(text: [*:0]const u8) void {
    if (enable)
        c.___tracy_emit_message(text, @boolToInt(true));
}
pub inline fn messageDynamicC(text: []const u8, color: u32) void {
    if (enable)
        c.___tracy_emit_message(text.ptr, text.len, color, @boolToInt(true));
}
pub inline fn messageStaticC(text: [*:0]const u8, color: u32) void {
    if (enable)
        c.___tracy_emit_message(text, color, @boolToInt(true));
}

pub inline fn frameMark(name: ?[*:0]const u8) void {
    if (enable)
        c.___tracy_emit_frame_mark(name);
}
pub inline fn frameMarkStart(name: ?[*:0]const u8) void {
    if (enable)
        c.___tracy_emit_frame_mark_start(name);
}
pub inline fn frameMarkEnd(name: ?[*:0]const u8) void {
    if (enable)
        c.___tracy_emit_frame_mark_end(name);
}
pub inline fn frameMarkImage(image: [*]const c_void, w: u16, h: u16, offset: u8, flip: bool) void {
    if (enable)
        c.___tracy_emit_frame_image(image, w, h, offset, @boolToInt(flip));
}

pub inline fn plot(name: [*:0]const u8, val: c_double) void {
    if (enable)
        c.___tracy_emit_plot(name, val);
}

pub inline fn appInfo(text: []const u8) void {
    if (enable)
        c.___tracy_emit_message_appinfo(text.ptr, text.len);
}
