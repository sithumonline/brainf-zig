const std = @import("std");

const stdout = std.io.getStdOut();
const stdin = std.io.getStdIn();

fn exeute(program: []const u8) !void {
    var memory = [_]u8{0} ** 3000;
    var dataPtr: usize = 0;

    var instructionPtr: usize = 0;

    for (program) |char| {
        switch (char) {
            '+' => {
                memory[dataPtr] += 1;
            },
            '-' => {
                if (memory[dataPtr] > 0) {
                    memory[dataPtr] -= 1;
                }
            },
            '>' => {
                if (dataPtr < memory.len - 1) {
                    dataPtr += 1;
                }
            },
            '<' => {
                if (dataPtr > 0) {
                    dataPtr -= 1;
                }
            },
            '.' => {
                try stdout.writer().print("\"{c}\"\n", .{memory[dataPtr]});
            },
            ',' => {
                try stdout.writeAll(
                    \\input: 
                );
                var buffer: [2]u8 = undefined;
                const input = (try nextLine(stdin.reader(), &buffer)).?;
                memory[dataPtr] = input[0];
            },
            '[' => {
                if (memory[dataPtr] == 0) {
                    var nestDepth: usize = 1;
                    for (0..nestDepth) |_| {
                        instructionPtr += 1;
                        switch (program[instructionPtr]) {
                            '[' => nestDepth += 1,
                            ']' => nestDepth -= 1,
                            else => {},
                        }
                    }
                }
            },
            ']' => {
                if (memory[dataPtr] != 0) {
                    var nestDepth: usize = 1;
                    for (0..nestDepth) |_| {
                        instructionPtr -= 1;
                        switch (program[instructionPtr]) {
                            ']' => nestDepth += 1,
                            '[' => nestDepth -= 1,
                            else => {},
                        }
                    }
                }
            },
            else => {},
        }
        instructionPtr += 1;
    }
}

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    const line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

pub fn main() !void {
    var buffer: [3000]u8 = undefined;
    const input = (try nextLine(stdin.reader(), &buffer)).?;

    try exeute(input);
}

test "hello world" {
    try exeute("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.,+[-.[-]-,+].");
}
