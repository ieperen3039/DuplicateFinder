const std = @import("std");
const duplicate_finder = @import("duplicate_finder");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("inputs/LorumIpsum.txt", .{});
    defer file.close();

    duplicate_finder.findDuplicates(file.reader());
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
