const std = @import("std");
const lex = @import("lexer");

pub fn main() !void {
    var lexer = lex.init("()*{};,.<=<<>>>=\"test\"");

    std.debug.print("Input: {s}\n", .{lexer.input});

    while (true) {
        const token = lexer.next();
        if (token.type == lex.TokenType.EOF) {
            break;
        }
        std.debug.print("{any}\n", .{token.type});
    }
}
