const std = @import("std");
const stdout = std.io.getStdOut();
const MAX_INT = std.math.maxInt(i32);
 
pub fn main() !void{
	const pat1: []const u8 = ".";
	const pat2: []const u8 = "monisha";
	const pat3: []const u8 = "susmit";

	const strarr = [_][]const u8{"hello", "hello world", "monisha.jpg", "monishamonisha", "susmitsusmit", "monishamonishamonishamonisha", "susmit", "susmitsusmitsusmitsusmit", "monishamonishamonishamonishamonishamonishamonishamonishamonisha"};

	const atom1 = AtomicRegex.init(pat1, null, MAX_INT);
	const atom2 = AtomicRegex.init(pat2, 2, 5);
	const atom3 = AtomicRegex.init(pat3, 1, 3);
	const atoms = [3]AtomicRegex{atom1, atom2, atom3};

	var res: bool = undefined;

	var value: i32 = 0;
	const ptr: *i32 = &value;
	const val2 = ptr.* + 2;

	try stdout.writer().print("Value: {d}, Value-2: {d}\n", .{value, val2});

	var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const alloc = gpa.allocator();
	
	for (strarr) |str| {
		for (atoms) |atom| {
			const pos_ptr = try alloc.create(usize);
			pos_ptr.* = 0;
			res = atom.match(str, pos_ptr);

			try stdout.writer().print("Testing pattern \"{s}[{d}, {d}]\" against string \"{s}\"... Result: \"{}\"\n", .{atom.pattern, atom.lower_lim, atom.upper_lim, str, res});
		}
	}
}

const AtomicRegex = struct {
	pattern: []const u8,
	lower_lim: usize = 1,
	upper_lim: usize = 1,
	
	pub fn init(pattern: []const u8, llim: ?usize, ulim: ?usize) AtomicRegex{
		return AtomicRegex{
			.pattern = pattern,
			.lower_lim = llim orelse 1,
			.upper_lim = ulim orelse 1
		};
	}
	
	pub fn match(self: AtomicRegex, string: []const u8, pos_ptr: *usize) bool {
		var patcount: i32 = 0;
		var cursor = pos_ptr.*;
		if (std.mem.eql(u8, self.pattern, ".")){
			while (cursor < string.len){
				for (0..self.pattern.len) |_|{
					if (string[pos_ptr.*] != '\n'){
						cursor += 1;
					} else break;
				}
				patcount += 1;
			}
		} else {

			outer: while (cursor < string.len){
				for (0..self.pattern.len) |i|{
					if (string[cursor] != self.pattern[i]) {
						break :outer;
					}
					cursor += 1;
				}
				patcount += 1;
			}
		}
		std.debug.print("====Patcount from {s}: {d}====\n====Cursor loc: {d}====\n",.{self.pattern, patcount, cursor});
		if (patcount <= self.upper_lim and patcount >= self.lower_lim){
			return true;
		}
		return false;
	}
};
