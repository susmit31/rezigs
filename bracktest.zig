const std = @import("std");

pub fn main() void{
	const string = "[[Jj][Pp][Ee]]?[Gg]";

	std.debug.print("Input: {s},\nOutput: {s}\n", .{string, extract_bracket(string, '[')});
}

pub fn extract_bracket(string: []const u8, bracket: ?u8) []const u8{
	var i: usize = 0;
	var start: usize = undefined;
	var end: usize = undefined;
	var count: i32 = undefined;
	var char: u8 = undefined;
	const startbrace = bracket orelse '(';
	var closebrace: u8 = undefined;

	if (startbrace == '(') {
		closebrace = ')';
	} else if (startbrace == '{') {
		closebrace = '}';
	} else if (startbrace == '[') {
		closebrace = ']';
	}
	
	while (i < string.len){
		char = string[i];
		if (char == startbrace){
			count = 1;
			start = i;
			i += 1;
			while (count != 0 and i < string.len) {
				char = string[i];
				if (char == closebrace){
					count -= 1;
				} else if (char == startbrace){
					count += 1;
				}
				i += 1;
			}
			if (count == 0) {
				end = i;
				break;
			}
		}
		i += 1;
	}
	return string[start+1..end-1];
}
