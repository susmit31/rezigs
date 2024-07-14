fn todo() void{
	
}

const Expr = struct{
	pattern: []const u8,

	pub fn parse(self: Expr) ParsedTree {
		todo();
	}

	pub fn match(self: Expr, string: []const u8) bool {
		return self.parse().match(string);
	}
}

const Node = struct{
	content: []const u8,
	qtifier: []const u8,
	parent: Node,
	children: []Node,
	ops: []u8,

	pub fn match(self: Node, loc_ptr: *i32) bool{
		var result = true;
		var currval: bool = undefined;
		if (self.is_leaf()) {
			todo();
		} else {
			for (self.children, 0..) |child, i|{
				currval = child.match(string, loc_ptr);
				result = operate(result, currval);
			}
		}

		return result;
	}

	pub fn is_leaf(self: Node) bool{
		if (self.children.len == 0) return true;
		return false;
	}
}

const ParsedTree = struct{
	pattern: []const u8,
	root: Node,

	pub fn match(self: ParsedTree, string: []const u8) bool {
		var pos: i32 = 0;
		const pos_ptr: *i32 = &pos;

		return self.root.match(string, pos_ptr);
	}
}

