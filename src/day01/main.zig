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

fn turnLock(current: i32, command: Command) struct { i32, i32 } {
    var zeroes: i32 = 0;
    var new: i32 = current;

    var i: usize = 0;
    while (i < command.turn) : (i += 1) {
        new = switch (command.direction) {
            .LEFT => new - 1,
            .RIGHT => new + 1,
        };
        new = @mod(new, 100);
        if (new == 0) zeroes += 1;
    }

    return .{ new, zeroes };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var iter = try common.makeFileIterator(allocator, "src/day01/input.txt");
    defer iter.deinit();

    var current: i32 = 50;
    var zeroes: i32 = 0;
    var result: u16 = 0;
    var total: u16 = 0;

    while (try iter.next()) |line| {
        // std.debug.print("line: {s}\n", .{maybe_line});

        const cmd = try parseCommand(line);
        current, zeroes = turnLock(current, cmd);
        result += @intCast(zeroes);
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
