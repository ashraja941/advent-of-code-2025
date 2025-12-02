const std = @import("std");
const common = @import("common");

const expect = std.testing.expect;

const Directions = enum {
    LEFT,
    RIGHT,
};

const Command = struct {
    direction: Directions,
    turn: i32,
};

fn parseCommand(line: []const u8) !Command {
    if (line.len < 2) {
        std.debug.print("{s}", .{line});
        return error.InvalidCommand;
    }

    const dir = switch (line[0]) {
        'L' => Directions.LEFT,
        'R' => Directions.RIGHT,
        else => return error.InvalidCommand,
    };

    // const number = line[1 .. line.len - 1];
    const raw_number = std.mem.trim(u8, line[1..], " \r\n");
    const turns: i32 = try std.fmt.parseInt(i32, raw_number, 10);

    return Command{ .direction = dir, .turn = turns };
}

fn turnLock(current: i32, command: Command) i32 {
    var new = switch (command.direction) {
        .LEFT => current - command.turn,
        .RIGHT => current + command.turn,
    };

    new = @mod(new, 100);
    return new;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var iter = try common.makeFileIterator(allocator, "src/day01/input.txt");
    defer iter.deinit();

    var current: i32 = 50;
    var result: u16 = 0;
    var total: u16 = 0;

    while (try iter.next()) |line| {
        // std.debug.print("line: {s}\n", .{maybe_line});

        const cmd = try parseCommand(line);
        current = turnLock(current, cmd);
        if (current == 0) result += 1;
        total += 1;

        // std.debug.print("Parsed: dir = {s}, distance = {}\n", .{
        //     switch (cmd.direction) {
        //         .LEFT => "left",
        //         .RIGHT => "right",
        //     },
        //     cmd.turn,
        // });
    }

    std.debug.print("Final Answer : {d}\n", .{result});
    std.debug.print("Total lines parsed : {d}", .{total});
}

test "over 100" {
    const new = turnLock(99, Command{ .direction = .RIGHT, .turn = 1 });
    try expect(new == 0);
}

test "under 0" {
    const new = turnLock(0, Command{ .direction = .LEFT, .turn = 1 });
    try expect(new == 99);
}
test "turn lock wrap-around (existing tests)" {
    // Existing "over 100" test
    const new_over = turnLock(99, Command{ .direction = .RIGHT, .turn = 1 });
    try expect(new_over == 0);

    // Existing "under 0" test
    const new_under = turnLock(0, Command{ .direction = .LEFT, .turn = 1 });
    try expect(new_under == 99);

    // New test: L10 from 5 should be 95 (5 - 10 = -5, -5 + 100 = 95)
    const new_l10 = turnLock(5, Command{ .direction = .LEFT, .turn = 10 });
    try expect(new_l10 == 95);

    // New test: R1 from 99 should be 0 (99 + 1 = 100, 100 % 100 = 0)
    const new_r1 = turnLock(99, Command{ .direction = .RIGHT, .turn = 1 });
    try expect(new_r1 == 0);
}

test "advent of code day 1 example sequence" {
    // The rotations provided in the puzzle example:
    const commands = [_]Command{
        .{ .direction = .LEFT, .turn = 68 }, // L68
        .{ .direction = .LEFT, .turn = 30 }, // L30
        .{ .direction = .RIGHT, .turn = 48 }, // R48
        .{ .direction = .LEFT, .turn = 5 }, // L5
        .{ .direction = .RIGHT, .turn = 60 }, // R60
        .{ .direction = .LEFT, .turn = 55 }, // L55
        .{ .direction = .LEFT, .turn = 1 }, // L1
        .{ .direction = .LEFT, .turn = 99 }, // L99
        .{ .direction = .RIGHT, .turn = 14 }, // R14
        .{ .direction = .LEFT, .turn = 82 }, // L82
    };

    var current_pos: i32 = 50; // Starts at 50
    var zero_hits: u16 = 0;

    // The expected sequence of positions:
    // 50 -> 82 -> 52 -> 0 (HIT 1) -> 95 -> 55 -> 0 (HIT 2) -> 99 -> 0 (HIT 3) -> 14 -> 32

    // 1. L68: 50 - 68 = -18. (-18 % 100 + 100) % 100 = 82
    current_pos = turnLock(current_pos, commands[0]);
    try expect(82 == current_pos);

    // 2. L30: 82 - 30 = 52.
    current_pos = turnLock(current_pos, commands[1]);
    try expect(52 == current_pos);

    // 3. R48: 52 + 48 = 100. (100 % 100 + 100) % 100 = 0. (HIT 1)
    current_pos = turnLock(current_pos, commands[2]);
    if (current_pos == 0) zero_hits += 1;
    try expect(0 == current_pos);

    // 4. L5: 0 - 5 = -5. (-5 % 100 + 100) % 100 = 95.
    current_pos = turnLock(current_pos, commands[3]);
    try expect(95 == current_pos);

    // 5. R60: 95 + 60 = 155. (155 % 100) = 55.
    current_pos = turnLock(current_pos, commands[4]);
    try expect(55 == current_pos);

    // 6. L55: 55 - 55 = 0. (HIT 2)
    current_pos = turnLock(current_pos, commands[5]);
    if (current_pos == 0) zero_hits += 1;
    try expect(0 == current_pos);

    // 7. L1: 0 - 1 = -1. (-1 % 100 + 100) % 100 = 99.
    current_pos = turnLock(current_pos, commands[6]);

    try expect(99 == current_pos);

    // 8. L99: 99 - 99 = 0. (HIT 3)
    current_pos = turnLock(current_pos, commands[7]);
    if (current_pos == 0) zero_hits += 1;
    try expect(0 == current_pos);

    // 9. R14: 0 + 14 = 14.
    current_pos = turnLock(current_pos, commands[8]);
    try expect(14 == current_pos);

    // 10. L82: 14 - 82 = -68. (-68 % 100 + 100) % 100 = 32.
    current_pos = turnLock(current_pos, commands[9]);
    try expect(32 == current_pos);

    // Final assertion: the puzzle states the answer should be 3.
    try expect(3 == zero_hits);
}
