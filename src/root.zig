//! By convention, root.zig is the root source file when making a library.
const std = @import("std");

pub const TokenType = enum {
    // Single-character tokens.
    LEFT_PAREN,
    RIGHT_PAREN,
    LEFT_BRACE,
    RIGHT_BRACE,
    COMMA,
    DOT,
    MINUS,
    PLUS,
    SEMICOLON,
    SLASH,
    STAR,

    // One or two character tokens.
    BANG,
    BANG_EQUAL,
    EQUAL,
    EQUAL_EQUAL,
    GREATER,
    GREATER_EQUAL,
    LESS,
    LESS_EQUAL,

    // Literals.
    IDENTIFIER,
    STRING,
    NUMBER,

    // Keywords.
    AND,
    CLASS,
    ELSE,
    FALSE,
    FUN,
    FOR,
    IF,
    NIL,
    OR,
    PRINT,
    RETURN,
    SUPER,
    THIS,
    TRUE,
    VAR,
    WHILE,

    EOF,
};

pub const Token = struct {
    type: TokenType,
    val: [:0]const u8,
};

pub fn init(input: [:0]const u8) Lexer {
    return Lexer{
        .input = input,
        .rest = @constCast(input),
        .pos = 0,
    };
}

pub const Lexer = struct {
    input: [:0]const u8,
    rest: [:0]u8,
    pos: usize,

    fn peek(self: *Lexer) u8 {
        if (self.pos >= self.input.len) {
            return 0;
        }
        return self.input[self.pos];
    }

    fn advance(self: *Lexer) u8 {
        const char = self.rest[0];
        self.pos += 1;
        self.rest = self.rest[1..];
        return char;
    }

    pub fn next(self: *Lexer) Token {
        if (self.pos >= self.input.len) {
            return Token{
                .type = TokenType.EOF,
                .val = "",
            };
        }

        const char = self.advance();

        switch (char) {
            '+' => {
                return Token{
                    .type = TokenType.PLUS,
                    .val = "+",
                };
            },
            '*' => {
                return Token{
                    .type = TokenType.STAR,
                    .val = "*",
                };
            },
            '-' => {
                return Token{
                    .type = TokenType.MINUS,
                    .val = "-",
                };
            },
            '/' => {
                return Token{
                    .type = TokenType.SLASH,
                    .val = "/",
                };
            },
            '.' => {
                return Token{
                    .type = TokenType.DOT,
                    .val = ".",
                };
            },
            ',' => {
                return Token{
                    .type = TokenType.COMMA,
                    .val = ",",
                };
            },
            ';' => {
                return Token{
                    .type = TokenType.SEMICOLON,
                    .val = ";",
                };
            },
            '{' => {
                return Token{
                    .type = TokenType.LEFT_BRACE,
                    .val = "{",
                };
            },
            '}' => {
                return Token{
                    .type = TokenType.RIGHT_BRACE,
                    .val = "}",
                };
            },
            '(' => {
                return Token{
                    .type = TokenType.LEFT_PAREN,
                    .val = "(",
                };
            },
            ')' => {
                return Token{
                    .type = TokenType.RIGHT_PAREN,
                    .val = ")",
                };
            },
            '<' => {
                if (self.peek() == '=') {
                    self.pos += 1;
                    self.rest = self.rest[1..];
                    return Token{
                        .type = TokenType.LESS_EQUAL,
                        .val = "<=",
                    };
                } else {
                    return Token{
                        .type = TokenType.LESS,
                        .val = "<",
                    };
                }
            },
            '>' => {
                if (self.peek() == '=') {
                    self.pos += 1;
                    self.rest = self.rest[1..];
                    return Token{
                        .type = TokenType.GREATER_EQUAL,
                        .val = ">=",
                    };
                } else {
                    return Token{
                        .type = TokenType.GREATER,
                        .val = ">",
                    };
                }
            },
            '"' => {
                const starting = self.pos;
                while (self.advance() != '"') {}

                //TODO: allocate the memory for the string
                //const string: []u8 = undefined;
                //@memcpy(string, self.input[starting..self.pos]);
                std.debug.print("from:{}, to:{}\n", .{ starting, self.pos });
                return Token{
                    .type = TokenType.STRING,
                    .val = "",
                };
            },
            else => {
                unreachable;
            },
        }
    }
};

test "simple lexing" {
    var lexer = Lexer.init("+");

    try std.testing.expect(lexer.next().type == TokenType.PLUS);
    try std.testing.expect(lexer.next().type == TokenType.EOF);
}
