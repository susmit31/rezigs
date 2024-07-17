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
	lower_lim: i32 = 1,
	upper_lim: i32 = 1,

	pub fn init(variety: NodeType, content: []const u8, parent: ?Node, children: []Node, llim:?i32, ulim: ?i32) Node{
		return Node{
			.variety = variety,
			.content = content,
			.parent = parent,
			.children = children,
			.lower_lim = llim orelse 1,
			.upper_lim = ulim orelse 1
		};
	}

	pub fn match(self: Node, string: []const u8, pos_ptr: *i32) bool {
		const pos: i32 = pos_ptr.*;
		const substr = string[pos..];
		var res: bool = true;
		if (self.variety == .TXT_NODE){
			const atom = AtomicRegex.init(self.content, self.qtifier);
			return atom.match(substr, pos)
		} else {
			for (self.children)|child|{
				res = operate(res, self.content, child.match(string, pos_ptr));
			}
			return res;
		}
	}
};

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
};

const AtomicRegex = struct {
	pattern: []const u8,
	lower_lim: usize = 1,
	upper_lim: usize = 1,
	
	pub fn init(pattern: []const u8, llim: ?i32, ulim: ?i32) AtomicRegex{
		return AtomicRegex{
			.pattern = pattern,
			.lower_lim = llim orelse 1,
			.upper_lim = ulim orelse 1
		};
	}
	
	pub fn match(self: AtomicRegex, string: []const u8, pos_ptr: *usize) bool {
		var patcount: i32 = 0;
		if (std.mem.eql(u8, self.pattern, ".")){
			while (pos_ptr.* < string.len){
				for (0..self.pattern.len) |_|{
					if (string[pos_ptr.*] != '\n'){
						pos_ptr.* += 1;
					} else break;
				}
				patcount += 1;
			}
		} else {
			var cursor = pos_ptr.*;

			outer: while (cursor < string.len){
				for (0..self.pattern.len) |i|{
					if (string[cursor] != self.pattern[i]) {
						break :outer;
					} else {
						cursor += 1;
					}
					patcount += 1;
				}
			}
		}

		if (patcount <= self.upper_lim and patcount >= self.lower_lim){
			return true;
		}
		return false;
	}
};
