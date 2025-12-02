const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

fn findInvalidInRange(start: u64, end: u64) !u64 {
    var numInvalid: u64 = 0;

    for (start..end + 1) |i| {
        if (i < 10) continue;

        var buffer: [30]u8 = undefined;
        const str = try std.fmt.bufPrint(&buffer, "{d}", .{i});
        const len: u8 = @intCast(str.len);
        // const half: u8 = @divFloor(len, 2);

        for (2..len + 1) |parts| {
            const partInt: u8 = @intCast(parts);
            if (len % partInt != 0) continue;
            const chunk: u8 = @intCast(len / parts);
            var invalidBool: bool = true;

            for (1..parts) |part| {
                const partStart: u8 = @intCast(part * chunk);
                if (!std.mem.eql(u8, str[partStart .. partStart + chunk], str[0..chunk])) {
                    invalidBool = false;
                    break;
                }
            }
            if (invalidBool) {
                numInvalid += @intCast(i);
                print("invalid : {d}\n", .{i});
                break;
            }
        }
    }
    return numInvalid;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var iter = try common.makeFileIterator(allocator, "src/day02/input.txt", ',');
    defer iter.deinit();

    var totalInvalid: u64 = 0;

    while (try iter.next()) |line| {
        // print("range : {s}\n", .{line});

        const lineTrimmed = std.mem.trim(u8, line[0..], "\r\n");
        var stringIter = std.mem.splitScalar(u8, lineTrimmed, '-');
        const left = stringIter.next() orelse return error.BadFormat;
        const right = stringIter.next() orelse return error.BadFormat;

        const start: u64 = try std.fmt.parseInt(u64, left, 10);
        const end: u64 = try std.fmt.parseInt(u64, right, 10);

        print("start : {d}, end : {d}\n", .{ start, end });

        totalInvalid += try findInvalidInRange(start, end);
        print("\n", .{});
    }
    print("Final Anser : {d}", .{totalInvalid});
}
