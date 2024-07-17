const std = @import("std");
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

pub fn main() !void{
	try stdout.writer().print("Welcome to ReZigs1.0, interactive mode.\n",.{});
	var buffer: [1024]u8 = undefined;
	var input: []const u8 = undefined;

	while (true){
		try stdout.writer().print(">> ",.{});
		input = (try stdin.reader().readUntilDelimiterOrEof(buffer,'\n')).?;

		if (input.len < 1) continue;
		else {
			
		}
	}
}
