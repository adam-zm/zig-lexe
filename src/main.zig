const std = @import("std");
const lex = @import("lexer");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x, y) {
        \\    x + y;
        \\};
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\if (5 < 10) {
        \\    return true;
        \\} else {
        \\    return false;
        \\}
        \\10 == 10;
        \\10 != 9;
    ;
    var lexer = lex.init(input, allocator);
    defer lexer.deinit();

    std.debug.print("Input: {s}\n", .{lexer.input});

    while (true) {
        const token = try lexer.next();
        defer token.deinit(allocator);
        if (token.type == .EOF) break;
        std.debug.print("{any} -> {s}\n", .{ token.type, token.val });
    }
}
