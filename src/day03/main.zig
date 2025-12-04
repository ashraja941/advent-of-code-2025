const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

fn processLine(line: []const u8) !u64 {
    const len = line.len;
    var maxFound: u64 = 0;

    maxFound = maxDigits(line[0 .. len - 1], 12).?;
    return maxFound;
}

fn maxDigits(line: []const u8, count: u8) ?u64 {
    if (count > line.len) return null;
    if (count == 0) return 0;
    const zeroValue: u8 = @intCast('0');

    var target: u8 = 9;
    while (target >= 0) : (target -= 1) {
        for (line, 0..) |numChar, i| {
            const num = numChar - zeroValue;
            if (num != target) continue;

            if (maxDigits(line[i + 1 ..], count - 1)) |recur| {
                const power = std.math.pow(u64, 10, count - 1);
                return num * power + recur;
            }
        }
    }

    return null;
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
