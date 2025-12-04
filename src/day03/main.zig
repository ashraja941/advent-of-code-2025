const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

fn processLine(line: []const u8) !u64 {
    const len = line.len;
    var maxFound: u64 = 0;
    const zeroValue: u8 = @intCast('0');

    for (0..len - 2) |i| {
        var buffer: [100]u8 = undefined;
        for (i + 1..len - 1) |j| {
            // print("{d} : {d}{d}\n", .{ j, line[i], line[j] });
            const newNumStr = try std.fmt.bufPrint(&buffer, "{d}{d}", .{ line[i] - zeroValue, line[j] - zeroValue });
            const newNum = try std.fmt.parseInt(u64, newNumStr, 10);

            if (newNum > maxFound) {
                maxFound = newNum;
            }
        }
    }

    return maxFound;
}

pub fn main() !void {
    print("Day 3 Running...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var iter = try common.makeFileIterator(allocator, "src/day03/input.txt", '\n');
    defer iter.deinit();

    var finalAnswer: u64 = 0;
    while (try iter.next()) |line| {
        finalAnswer += try processLine(line);
    }
    print("final answer : {d}", .{finalAnswer});
}

test "zero value" {
    const zeroValue: u8 = @intCast('0');
    print("Zero Value : {d}", .{zeroValue});
}
