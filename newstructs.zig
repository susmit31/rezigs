const std = @import("std");

const NodeType = enum {
	OP_NODE,
	TXT_NODE
};

const Node = struct {
	variety: NodeType,
	content: []const u8,
	parent: Node,
	children: []Node,
	qtifier: ?[]const u8,

	pub fn eval (self: Node) bool{
		var res = true;

		if (self.variety == .TXT_NODE){
			todo();
		} else {
			for (self.children) |child|{
				res = operate(res, child.eval(), content);
			}
		}

		return res;
	}

	pub fn match(self: Node, string: []const u8, pos_ptr: *i32) bool {
		const pos = pos_ptr.*;
		const substr = string[pos..];

		const atom = AtomicRegex{.pattern = self.content};
		return atom.match(substr, pos);
	}
}

const ParsedTree = struct {
	pattern: []const u8,
	root: Node,
	leaves: []Node,

	pub fn match(self: ParsedTree, string: []const u8) bool{
		var pos: i32 = 0;
		const pos_ptr: *i32 = &pos;

		return self.root.match(string, pos_ptr);
	}
}

const AtomicRegex = struct {
	pattern: []const u8,

	pub fn match(self: AtomicRegex, string: []const u8, pos_ptr: *i32) bool {
		return true;
	}
}
