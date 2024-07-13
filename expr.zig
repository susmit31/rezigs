const std = @import("std");

pub struct Expr {
	pattern: []const u8,
	qtfier: ?u8 = null,
	children: []Expr,
	ops: []u8,

	pub fn init(pattern: []const u8, qtfier: ?u8, children: []Expr, ops: []u8) Expr{
		return Expr {
			.pattern = pattern,
			.qtifier = qtifier,
			.children = children,
			.ops = ops
		};
	}

	pub fn match(self: Expr, string: []const u8, start: ?i32) bool{
		if (children.len == 0) {
			return std.mem.eql(u8, self.pattern, string);
		} else {
			var curr_result: bool = undefined;
			var prev_result: bool = true;
			var curr_pos: i32 = start orelse 0;
			for (0..children.len-1) |i| {
				curr_result = children[i].match(string, curr_pos);
				curr_pos = curr_pos + children[i].len;
				
				prev_result = switch(ops[i]) {
					'|' => curr_result or prev_result,
					'&' => curr_result and prev_result,
				};
			}
			return prev_result;
		}
	}

}

pub fn make_tree(pattern: []const u8) Expr{
	var qtfier: ?u8 = null;
	var children: [32]Expr = undefined;
}
