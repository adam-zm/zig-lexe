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
            (char == '_');
    }

    fn isNumber(char: u8) bool {
        return (char >= '0' and char <= '9');
    }

    fn isWhitespave(char: u8) bool {
        return (char == ' ') or
            (char == '\n') or
            (char == '\r') or
            (char == '\t');
    }

    fn matchKeywords(slice: [:0]const u8) anyerror!Token {
        if (std.mem.eql(u8, slice, "and")) {
            return Token{
                .type = .AND,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "class")) {
            return Token{
                .type = .CLASS,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "else")) {
            return Token{
                .type = .ELSE,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "false")) {
            return Token{
                .type = .FALSE,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "true")) {
            return Token{
                .type = .TRUE,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "fun")) {
            return Token{
                .type = .FUN,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "for")) {
            return Token{
                .type = .FOR,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "or")) {
            return Token{
                .type = .OR,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "if")) {
            return Token{
                .type = .IF,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "nil")) {
            return Token{
                .type = .NIL,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "print")) {
            return Token{
                .type = .PRINT,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "return")) {
            return Token{
                .type = .RETURN,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "super")) {
            return Token{
                .type = .SUPER,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "while")) {
            return Token{
                .type = .WHILE,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "this")) {
            return Token{
                .type = .THIS,
                .val = slice,
                .is_allocated = true,
            };
        } else if (std.mem.eql(u8, slice, "var")) {
            return Token{
                .type = .VAR,
                .val = slice,
                .is_allocated = true,
            };
        } else {
            return error.InvalidKeyword;
        }
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
                '=' => {
                    if (self.peek() == '=') {
                        _ = self.advance();
                        return Token{
                            .type = .EQUAL_EQUAL,
                            .val = "==",
                            .is_allocated = false,
                        };
                    } else {
                        return Token{
                            .type = .EQUAL,
                            .val = "=",
                            .is_allocated = false,
                        };
                    }
                },
                '!' => {
                    if (self.peek() == '=') {
                        _ = self.advance();
                        return Token{
                            .type = .BANG_EQUAL,
                            .val = "!=",
                            .is_allocated = false,
                        };
                    } else {
                        return Token{
                            .type = .BANG,
                            .val = "!",
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
                        while (isIdentChar(self.peek()) or isNumber(self.peek())) {
                            if (self.pos >= self.input.len) break;
                            self.pos += 1;
                            self.rest = self.rest[1..];
                        }
                        const ident_slice = self.input[starting..self.pos];
                        const null_term = try self.allocator.dupeZ(u8, ident_slice);

                        return matchKeywords(null_term) catch {
                            return Token{
                                .type = .IDENTIFIER,
                                .val = null_term,
                                .is_allocated = true,
                            };
                        };
                    } else if (isNumber(char)) {
                        const starting = self.pos - 1;
                        while (isNumber(self.peek())) {
                            if (self.pos >= self.input.len) break;
                            self.pos += 1;
                            self.rest = self.rest[1..];
                        }
                        const ident_slice = self.input[starting..self.pos];
                        const null_term = try self.allocator.dupeZ(u8, ident_slice);
                        return Token{
                            .type = .NUMBER,
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
