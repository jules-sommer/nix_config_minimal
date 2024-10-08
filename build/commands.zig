const std = @import("std");

pub const RebuildAction = enum {
    /// Build and activate the new configuration, making it boot by default.
    @"switch",

    /// Build and activate the new configuartion, switching immediately as in
    /// "switch" - though only temporarily until reboot, but do not add it to
    /// the grub boot menu.
    @"test",
    /// Build the new configuration, but neither activate it nor add it to the
    /// GRUB boot  menu.
    build,

    /// Build the new configuration and  make  it  the  boot  default, as in "switch",
    /// but do not activate it.
    boot,

    const map = std.StaticStringMap(RebuildAction).initComptime(.{
        .{ "switch", .@"switch" },
        .{ "test", .@"test" },
        .{ "build", .build },
        .{ "boot", .boot },
    });

    pub fn fromBytes(bytes: []const u8) ?RebuildAction {
        return map.get(bytes);
    }
};
