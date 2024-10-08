const std = @import("std");
const Progress = std.Progress;
const ArenaAllocator = std.heap.ArenaAllocator;
const RebuildAction = @import("commands.zig").RebuildAction;

const OtherArg = union(enum) {
    scope: enum { home, system, all },
    action: RebuildAction,
    flake: []const u8,

    const tagNameMap = std.StaticStringMap(OtherArg).initComptime(.{
        .{ "scope", OtherArg{ .scope = .home } },
        .{ "action", OtherArg{ .action = RebuildAction.@"switch" } },
        .{ "flake", OtherArg{ .flake = "" } },
    });

    pub fn fromBytes(bytes: []const u8) ?OtherArg {
        return tagNameMap.get(bytes);
    }
};

const Argument = struct {
    key: []const u8,
    value: Value,

    const Value = union {
        action: RebuildAction,
        flake: []const u8,
        scope: enum { home, system, all },
    };
};

test "argument" {
    _ = Argument{ .key = "scope", .value = .{ .action = .@"test" } };
}

const ArgsError = error{
    InvalidArguments,
};

const argKeyIntMap = std.StaticStringMap(u8).initComptime(.{
    .{ "scope", 0 },
    .{ "action", 1 },
    .{ "flake", 2 },
});

const scopeIntMap = std.StaticStringMap(u8).initComptime(.{
    .{ "home", 0 },
    .{ "system", 1 },
    .{ "all", 2 },
});

pub fn main() !void {
    var arena = ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    _ = stdout; // autofix

    var processArgsIter = try std.process.argsWithAllocator(allocator);
    if (!processArgsIter.skip()) {
        return error.InvalidArguments;
    }

    // var inArgumentList = std.ArrayList(*Argument).init(allocator);

    while (processArgsIter.next()) |arg| {
        var splitEqualsIter = std.mem.splitScalar(u8, arg, '=');
        if (!std.mem.startsWith(u8, splitEqualsIter.peek().?, "--")) @panic("invalid argument");

        const argKey = std.mem.trimLeft(u8, splitEqualsIter.next().?, "-- \t\n\r");
        // const argVal = std.mem.trim(u8, splitEqualsIter.next().?, " \t\n\r");

        std.debug.print("argKey: {s}\n", .{argKey});
        const argKeyInt = argKeyIntMap.get(argKey);
        std.debug.print("argKeyInt: {d}\n", .{argKeyInt.?});

        // const nextArg = OtherArg.fromBytes(argKey);
        // if (nextArg) |na| {
        //     std.debug.print("{any}", .{na});
        // }
        // std.debug.print("nextArg{{\nkey: {s}\nvalue: {s}\n}}", .{ nextArg.key, nextArg.value });
        // inArgumentList.append(&nextArg);
        //
        // while (splitEqualsIter.next()) |command| {
        //     std.debug.print("[{s}]\n", .{command});
        //     if (std.mem.startsWith(u8, command, "--")) {
        //         nextArg.key = std.mem.trimLeft(u8, command, " -\t\n\r");
        //     }
        //
        //     try inArgumentList.append(nextArg);
        // }
    }

    // for (inArgumentList.items) |arg1| {
    //     std.debug.print("{s}\n", .{arg1.key});
    // }
    //
    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
