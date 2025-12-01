const std = @import("std");
const common = @import("common");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Day1 {s}", .{"codebase"});
    try common.bufferedPrint();
}
