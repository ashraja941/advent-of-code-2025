const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

fn sortAsc(comptime T: type) fn (void, T, T) bool {
    return struct {
        pub fn inner(_: void, a: T, b: T) bool {
            return a[0] < b[0];
        }
    }.inner;
}

fn mergeIntervals(allocator: std.mem.Allocator, list: std.array_list.Aligned([2]u64, null)) !std.array_list.Aligned([2]u64, null) {
    const len = list.items.len;

    var output = try std.ArrayList([2]u64).initCapacity(allocator, 50);
    try output.append(allocator, list.items[0]);

    var i: usize = 1;
    while (i < len) : (i += 1) {
        const lastEnd = output.items[output.items.len - 1][1];
        const start = list.items[i][0];
        const end = list.items[i][1];

        if (start <= lastEnd) {
            output.items[output.items.len - 1][1] = @max(lastEnd, end);
        } else {
            try output.append(allocator, .{ start, end });
        }
    }
    return output;
}

fn intervalsContainItem(intervals: std.array_list.Aligned([2]u64, null), item: u64) bool {
    for (intervals.items) |interval| {
        const start = interval[0];
        const end = interval[1];

        if (item >= start and item <= end) return true;
    }
    return false;
}

pub fn main() !void {
    print("Day 5 Running...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // var iter = try common.makeFileIterator(allocator, "src/day05/test.txt", '\n');
    var iter = try common.makeFileIterator(allocator, "src/day05/input.txt", '\n');
    defer iter.deinit();

    var ranges = try std.ArrayList([2]u64).initCapacity(allocator, 50);
    defer ranges.deinit(allocator);

    var guesses = try std.ArrayList(u64).initCapacity(allocator, 50);
    defer guesses.deinit(allocator);

    while (try iter.next()) |range| {
        const trimmed = if (range[range.len - 1] == '\r')
            range[0 .. range.len - 1]
        else
            range;

        if (trimmed.len == 0) break;

        print("[DEBUG] Line : {s}\n", .{trimmed});

        const copy = try allocator.alloc(u8, trimmed.len);
        std.mem.copyForwards(u8, copy, trimmed);

        var stringIter = std.mem.splitScalar(u8, copy, '-');
        const left = stringIter.next() orelse return error.BadFormat;
        const right = stringIter.next() orelse return error.BadFormat;

        const start: u64 = try std.fmt.parseInt(u64, left, 10);
        const end: u64 = try std.fmt.parseInt(u64, right, 10);

        try ranges.append(allocator, .{ start, end });
    }

    std.mem.sort([2]u64, ranges.items, {}, sortAsc([2]u64));
    print("[DEBUG] parsed ranges : {any}\n", .{ranges.items});

    const sorted = try mergeIntervals(allocator, ranges);
    print("[DEBUG] parsed sorted : {any}\n", .{sorted.items});

    var total: u64 = 0;
    for (sorted.items) |interval| {
        const start = interval[0];
        const end = interval[1];
        total += end - start + 1;
    }

    print("Final Output : {d}\n", .{total});
}
