const std = @import("std");
const lex = @import("lexer");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lexer = lex.init("()*{};,.<=<<>>>=\"test\"var let **", allocator);
    defer lexer.deinit();

    std.debug.print("Input: {s}\n", .{lexer.input});

    while (true) {
        const token = try lexer.next();
        defer token.deinit(allocator);
        if (token.type == .EOF) break;
        std.debug.print("{any} -> {s}\n", .{ token.type, token.val });
    }
}
