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
    is_allocated: bool,

    pub fn deinit(self: Token, allocator: std.mem.Allocator) void {
        if (self.is_allocated) {
            allocator.free(self.val);
        }
    }
};

pub fn init(input: [:0]const u8, allocator: std.mem.Allocator) Lexer {
    return Lexer{
        .input = input,
        .rest = @constCast(input),
        .pos = 0,
        .allocator = allocator,
    };
}

pub const Lexer = struct {
    input: [:0]const u8,
    rest: [:0]u8,
    pos: usize,
    allocator: std.mem.Allocator,

    fn peek(self: *Lexer) u8 {
        if (self.pos >= self.input.len) {
            return 0;
        }
        return self.input[self.pos];
    }

    fn advance(self: *Lexer) u8 {
        if (self.pos >= self.input.len) {
            return 0;
        }
        const char = self.rest[0];
        self.pos += 1;
        self.rest = self.rest[1..];
        return char;
    }

    fn isIdentChar(char: u8) bool {
        return (char >= 'a' and char <= 'z') or
            (char >= 'A' and char <= 'Z') or
            (char == '_') or
            (char >= '0' and char >= '9');
    }

    fn isWhitespave(char: u8) bool {
        return (char == ' ') or
            (char == '\n') or
            (char == '\r') or
            (char == '\t');
    }

    pub fn next(self: *Lexer) !Token {
        if (self.pos >= self.input.len) {
            return Token{
                .type = TokenType.EOF,
                .val = "",
                .is_allocated = false,
            };
        }

        while (true) {
            const char = self.advance();
            // std.debug.print("--{any} {s}--", .{ char, self.rest });

            switch (char) {
                '+' => {
                    return Token{
                        .type = TokenType.PLUS,
                        .val = "+",
                        .is_allocated = false,
                    };
                },
                '*' => {
                    return Token{
                        .type = TokenType.STAR,
                        .val = "*",
                        .is_allocated = false,
                    };
                },
                '-' => {
                    return Token{
                        .type = TokenType.MINUS,
                        .val = "-",
                        .is_allocated = false,
                    };
                },
                '/' => {
                    return Token{
                        .type = TokenType.SLASH,
                        .val = "/",
                        .is_allocated = false,
                    };
                },
                '.' => {
                    return Token{
                        .type = TokenType.DOT,
                        .val = ".",
                        .is_allocated = false,
                    };
                },
                ',' => {
                    return Token{
                        .type = TokenType.COMMA,
                        .val = ",",
                        .is_allocated = false,
                    };
                },
                ';' => {
                    return Token{
                        .type = TokenType.SEMICOLON,
                        .val = ";",
                        .is_allocated = false,
                    };
                },
                '{' => {
                    return Token{
                        .type = TokenType.LEFT_BRACE,
                        .val = "{",
                        .is_allocated = false,
                    };
                },
                '}' => {
                    return Token{
                        .type = TokenType.RIGHT_BRACE,
                        .val = "}",
                        .is_allocated = false,
                    };
                },
                '(' => {
                    return Token{
                        .type = TokenType.LEFT_PAREN,
                        .val = "(",
                        .is_allocated = false,
                    };
                },
                ')' => {
                    return Token{
                        .type = TokenType.RIGHT_PAREN,
                        .val = ")",
                        .is_allocated = false,
                    };
                },
                '<' => {
                    if (self.peek() == '=') {
                        self.pos += 1;
                        self.rest = self.rest[1..];
                        return Token{
                            .type = TokenType.LESS_EQUAL,
                            .val = "<=",
                            .is_allocated = false,
                        };
                    } else {
                        return Token{
                            .type = TokenType.LESS,
                            .val = "<",
                            .is_allocated = false,
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
                            .is_allocated = false,
                        };
                    } else {
                        return Token{
                            .type = TokenType.GREATER,
                            .val = ">",
                            .is_allocated = false,
                        };
                    }
                },
                '"' => {
                    const starting = self.pos;
                    while (self.pos < self.input.len and self.advance() != '"') {}

                    if (self.pos > self.input.len) {
                        return error.UnterminatedString;
                    }

                    const string_slice = self.input[starting .. self.pos - 1];
                    const null_terminated = try self.allocator.dupeZ(u8, string_slice);

                    return Token{
                        .type = TokenType.STRING,
                        .val = null_terminated,
                        .is_allocated = true,
                    };
                },
                else => {
                    if (isIdentChar(char)) {
                        const starting = self.pos - 1;
                        while (isIdentChar(self.peek())) {
                            if (self.pos >= self.input.len) break;
                            self.pos += 1;
                            self.rest = self.rest[1..];
                        }
                        const ident_slice = self.input[starting..self.pos];
                        const null_term = try self.allocator.dupeZ(u8, ident_slice);
                        return Token{
                            .type = .IDENTIFIER,
                            .val = null_term,
                            .is_allocated = true,
                        };
                    } else if (isWhitespave(char)) {
                        continue;
                    } else {
                        return error.InvalidCharacter;
                    }
                },
            }
        }
    }

    //not needed for now...
    pub fn deinit(_: *Lexer) void {}
};
