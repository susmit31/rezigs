const std = @import("std");

const NodeType = enum {
	OP_NODE,
	TXT_NODE
};

const Node = struct {
	variety: NodeType,
	content: []const u8,
	parent: ?Node,
	children: []Node,
	qtifier: ?[]const u8,

	pub fn init(variety: NodeType, content: []const u8, parent: ?Node, children: []Node, qtifier: ?[]const u8) Node{
		return Node{
			.variety = variety,
			.content = content,
			.parent = parent,
			.children = children,
			.qtifier = qtifier
		};
	}

	pub fn match(self: Node, string: []const u8, pos_ptr: *i32) bool {
		const pos: i32 = pos_ptr.*;
		const substr = string[pos..];
		var res: bool = true;
		if (self.variety == .TXT_NODE){
			const atom = AtomicRegex{.pattern = self.content};
			return atom.match(substr, pos)
		} else {
			for (self.children)|child|{
				res = operate(res, self.content, child.match(string, pos_ptr));
			}
			return res;
		}
	}
}

const ParsedTree = struct {
	pattern: []const u8,
	root: Node,
	leaves: []Node,

	pub fn init(pattern: []const u8, root: Node, leaves: []Node) ParsedTree{
		return ParsedTree{
			.pattern = pattern,
			.root = root,
			.leaves = leaves
		};
	}

	pub fn match(self: ParsedTree, string: []const u8) bool{
		var pos: i32 = 0;
		const pos_ptr: *i32 = &pos;

		return self.root.match(string, pos_ptr);
	}
}

const AtomicRegex = struct {
	pattern: []const u8,

	pub fn init(pattern: []const u8) AtomicRegex{
		return AtomicRegex{
			.pattern = pattern
		};
	}
	pub fn match(self: AtomicRegex, string: []const u8, pos_ptr: *i32) bool {
		return true;
	}
}
