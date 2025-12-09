const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

pub fn main() !void {
    print("Day 7 Running...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // var iter = try common.makeFileIterator(allocator, "src/day07/test.txt", '\n');
    var iter = try common.makeFileIterator(allocator, "src/day07/input.txt", '\n');
    defer iter.deinit();

    const startLine = try iter.next();
    const start = std.mem.indexOf(u8, startLine.?, "S").?;
    print("start : {d}", .{start});

    const len = startLine.?.len;
    print("current len : {d}", .{len});

    const length: usize = 142;

    var splits = [_]bool{false} ** length;
    splits[start] = true;
    // print("{any}\n", .{splits});

    var totalSplits: usize = 0;

    while (try iter.next()) |line| {
        if (line.len != length) unreachable;
        print("{s}\n", .{line});

        for (line, 0..) |l, i| {
            if (l != '^') continue;
            if (splits[i] != true) continue;

            totalSplits += 1;
            print("{d} ", .{i});

            if (i != 0) {
                splits[i - 1] = true;
            }
            if (i < len - 1) {
                splits[i + 1] = true;
            }
            splits[i] = false;
        }
        print("\n", .{});
        for (splits) |s| {
            if (s) {
                print("|", .{});
            } else {
                print(" ", .{});
            }
        }

        print("\n", .{});
    }

    print("final answer : {d}", .{totalSplits});
}
