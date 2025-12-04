const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;
const print = std.debug.print;

const directions = [_][2]i32{
    .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 },
    .{ 0, -1 },  .{ 0, 1 },  .{ 1, -1 },
    .{ 1, 0 },   .{ 1, 1 },
};

fn countAround(grid: std.array_list.Aligned([]u8, null), symbol: u8, r: usize, c: usize) u8 {
    const m: usize = grid.items.len;
    const n: usize = grid.items[0].len;
    var total: u8 = 0;

    const ir: i32 = @intCast(r);
    const ic: i32 = @intCast(c);

    for (directions) |direction| {
        const currentR = ir + direction[0];
        const currentC = ic + direction[1];

        if (currentR < 0 or currentR >= m or currentC < 0 or currentC >= n) continue;
        const tempR: usize = @intCast(currentR);
        const tempC: usize = @intCast(currentC);

        if (grid.items[tempR][tempC] != symbol) continue;
        total += 1;
    }
    return total;
}
fn countPaper(grid: std.array_list.Aligned([]u8, null)) !u64 {
    const m: usize = grid.items.len;
    const n: usize = grid.items[0].len;
    print("The size of the grid is {d}x{d}\n", .{ m, n });

    var totalPaper: u64 = 0;

    for (grid.items, 0..) |row, r| {
        for (row, 0..) |value, c| {
            if (row.len != grid.items[0].len) {
                print("Row length mismatch: {d} vs {d}\n", .{ row.len, grid.items[0].len });
            }
            if (value == '.') {
                print(".", .{});
                continue;
            }
            if (value != '@') unreachable;
            const around = countAround(grid, '@', r, c);
            print("{d}", .{around});
            if (around < 4) totalPaper += 1;
        }
        print("\n", .{});
        // print("{d}\n", .{totalPaper});
    }
    return totalPaper;
}

pub fn main() !void {
    print("Day 4 Running...\n", .{});

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // var iter = try common.makeFileIterator(allocator, "src/day04/test.txt", '\n');
    var iter = try common.makeFileIterator(allocator, "src/day04/input.txt", '\n');
    defer iter.deinit();

    var grid = try std.ArrayList([]u8).initCapacity(allocator, 50);
    defer grid.deinit(allocator);

    while (try iter.next()) |line| {
        if (line.len == 0) continue;
        const trimmed = if (line[line.len - 1] == '\r')
            line[0 .. line.len - 1]
        else
            line;

        const copy = try allocator.alloc(u8, trimmed.len);
        std.mem.copyForwards(u8, copy, trimmed);

        try grid.append(allocator, copy);
        print("{s}\n", .{line});
    }

    print("\n", .{});

    for (grid.items) |row| {
        for (row) |value| {
            print("{c}", .{value});
        }
        print("\n", .{});
    }

    print("Final Answer : {d}\n", .{try countPaper(grid)});
}
