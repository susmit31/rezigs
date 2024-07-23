const std = @import("std");

pub fn main() void{
	const str1 = "hellow? world";
	const str2 = "hello\\w? world";

	std.debug.print("String 1: {s},\nOutput: {s}\n\n", .{str1, backtrack(str1, 6)});
	std.debug.print("String 2: {s},\nOutput: {s}\n", .{str2, backtrack(str2, 7)});
}

pub fn backtrack(string: []const u8, pos: usize) []const u8{
	if (string[pos-2] != '\\') {
		return string[pos-1..pos];
	} else {
		return string[pos-2..pos];
	}
}
