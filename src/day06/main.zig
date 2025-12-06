const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

const operationsEnum = enum { ADD, MUL };

pub fn main() !void {
    print("Day 6 Running...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // var iter = try common.makeFileIterator(allocator, "src/day06/test.txt", '\n');
    var iter = try common.makeFileIterator(allocator, "src/day06/input.txt", '\n');
    defer iter.deinit();

    var lists: [4]std.ArrayList(u64) = undefined;
    for (&lists) |*list| {
        list.* = try std.ArrayList(u64).initCapacity(allocator, 50);
    }
    defer {
        for (&lists) |*list| {
            list.deinit(allocator);
        }
    }

    var operations = try std.ArrayList(operationsEnum).initCapacity(allocator, 50);
    defer operations.deinit(allocator);

    var i: usize = 0;
    while (try iter.next()) |range| {
        const trimmed = if (range[range.len - 1] == '\r')
            range[0 .. range.len - 1]
        else
            range;

        if (trimmed.len <= 1) continue;

        // print("[DEBUG] Line : {s}\n", .{trimmed});

        const copy = try allocator.alloc(u8, trimmed.len);
        std.mem.copyForwards(u8, copy, trimmed);

        var numIter = std.mem.splitScalar(u8, copy, ' ');
        while (numIter.next()) |numChar| {
            if (numChar.len == 0) continue;
            const num = std.fmt.parseInt(u64, numChar, 10) catch unreachable;
            try lists[i].append(allocator, num);
        }
        i += 1;
        if (i == 4) break;
    }

    while (try iter.next()) |line| {
        const trimmed = if (line[line.len - 1] == '\r')
            line[0 .. line.len - 1]
        else
            line;

        if (trimmed.len <= 1) continue;
        // print("[DEBUG] Line : {s}\n", .{trimmed});

        const copy = try allocator.alloc(u8, trimmed.len);
        std.mem.copyForwards(u8, copy, trimmed);

        var numIter = std.mem.splitScalar(u8, copy, ' ');
        while (numIter.next()) |numChar| {
            if (numChar.len == 0) continue;
            if (std.mem.eql(u8, numChar, "+")) {
                try operations.append(allocator, operationsEnum.ADD);
            } else {
                try operations.append(allocator, operationsEnum.MUL);
            }
        }
        i += 1;
        if (i == 4) break;
    }

    for (lists) |list| {
        // print("{any}\n", .{list});
        print("{d}\n", .{list.items.len});
    }

    print("{any}\n", .{operations.items.len});

    const numOperations = operations.items.len;
    var totalOutput: u64 = 0;

    for (0..numOperations) |operationIter| {
        if (operations.items[operationIter] == .ADD) {
            totalOutput += lists[0].items[operationIter] + lists[1].items[operationIter] + lists[2].items[operationIter] + lists[3].items[operationIter];
        } else {
            totalOutput += lists[0].items[operationIter] * lists[1].items[operationIter] * lists[2].items[operationIter] * lists[3].items[operationIter];
        }
    }

    print("total output : {d}", .{totalOutput});
}
