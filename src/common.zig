const std = @import("std");

pub const FileIterator = struct {
    file: std.fs.File,
    allocator: std.mem.Allocator,
    buffer: *[4096]u8,
    buffered_reader: std.fs.File.Reader,
    delimiter: u8,

    pub fn next(self: *FileIterator) !?[]u8 {
        return self.buffered_reader.interface.takeDelimiter(self.delimiter);
    }

    pub fn deinit(self: *FileIterator) void {
        self.file.close();
        self.allocator.destroy(self.buffer);
    }
};

pub fn makeFileIterator(
    allocator: std.mem.Allocator,
    file_path: []const u8,
    delimiter: u8,
) !FileIterator {
    const file = try std.fs.cwd().openFile(file_path, .{});

    // Allocate buffer on the heap instead of stack
    const buffer = try allocator.create([4096]u8);
    const buffered_reader = file.reader(buffer); // note: buffer is *[1024]u8

    return FileIterator{
        .file = file,
        .allocator = allocator,
        .buffer = buffer,
        .buffered_reader = buffered_reader,
        .delimiter = delimiter,
    };
}
