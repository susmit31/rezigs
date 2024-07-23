const std = @import("std");
const MAX_INT = std.math.maxInt(i64);

const NodeType = enum {
	OP_NODE,
	TXT_NODE
};

const Node = struct {
	variety: NodeType,
	content: []const u8,
	parent: ?*Node,
	children: []Node,
	lower_lim: i64 = 1,
	upper_lim: i64 = 1,

	pub fn init(variety: NodeType, content: []const u8, parent: ?*Node, children: []Node, llim:?i32, ulim: ?i32) Node{
		return Node{
			.variety = variety,
			.content = content,
			.parent = parent,
			.children = children,
			.lower_lim = llim orelse 1,
			.upper_lim = ulim orelse 1
		};
	}

	pub fn basic_init(variety: NodeType, content: []const u8) Node{
		return Node.init(variety, content, null, &[_]Node{}, null, null);
	}

	pub fn match(self: Node, string: []const u8, pos_ptr: *i32) bool {
		const pos: i32 = pos_ptr.*;
		const substr = string[pos..];
		var res: bool = true;
		if (self.variety == .TXT_NODE){
			const atom = AtomicRegex.init(self.content, self.qtifier);
			return atom.match(substr, pos);
		} else {
			for (self.children)|child|{
				res = operate(res, self.content, child.match(string, pos_ptr));
			}
			return res;
		}
	}

	pub fn leaves(self: Node, alloc: std.mem.Allocator) []Node{
		if (self.variety == .TXT_NODE) {
			var result = .{self};
			return result[0..];
		}
		var leaf_list = std.ArrayList(Node).init(alloc);
		for (self.children) |child|{
			for (child.leaves(alloc)) |leaf| {
				try leaf_list.append(leaf);
			}
		}

		return leaf_list.items;
	}

	pub fn print(self: Node) !void{
		const stdout = std.io.getStdOut();
		if (self.variety == .TXT_NODE) {
			try stdout.writer().print("[\"{s}\"${{{d},{d}}}$]", .{self.content, self.lower_lim, self.upper_lim});
		}
		else {
			try stdout.writer().print("{{<{s}>:", .{self.content});
			for (self.children) |child|{
				try stdout.writer().print(" ",.{});
				try child.print();
			}
			try stdout.writer().print("}}", .{});
		}
	}
};

const ParsedTree = struct {
	pattern: []const u8,
	root: Node,

	pub fn init(pattern: []const u8, root: Node) ParsedTree{
		return ParsedTree{
			.pattern = pattern,
			.root = root
		};
	}

	pub fn match(self: ParsedTree, string: []const u8) bool{
		var pos: i32 = 0;
		const pos_ptr: *i32 = &pos;

		return self.root.match(string, pos_ptr);
	}

	pub fn leaves(self: ParsedTree) []Node{
		var gpa = std.heap.GeneralPurposeAllocator(.{}){};
		const alloc = gpa.allocator();

		return self.root.leaves(alloc);
	}

	pub fn print(self: ParsedTree) !void{
		try self.root.print();
	}
};

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
		if (patcount <= self.upper_lim and patcount >= self.lower_lim){
			return true;
		}
		return false;
	}
};

pub fn parse_regex(pattern: []const u8) !ParsedTree{
	var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const alloc = gpa.allocator();
	
	var i: usize = 0;
	var last_node_end: usize = 0;
	var childlist_and = std.ArrayList(Node).init(alloc);
	var childlist_or = std.ArrayList(Node).init(alloc);
	var currnode: ?Node = null;
	var fullnode: Node = undefined;
	var text: []const u8 = undefined;
	var esc_seq: bool = false;
	
	while (i < pattern.len){
		if (esc_seq) {
			esc_seq = false;
			i+=1;
			continue;
		}
		switch(pattern[i]) {
			'(', '[' => {
				if (last_node_end < i){
					currnode = (try parse_regex(pattern[last_node_end..i])).root;
					try childlist_and.append(currnode.?);
					last_node_end = i+1;
				}
				text = extract_bracket(pattern[i..], pattern[i]);		
				currnode = (try parse_regex(text)).root ;
				try childlist_and.append(currnode.?);
				i += text.len+1;
				last_node_end = i+1;
			},
			'?', '*', '+' => {
				const bt_str = backtrack(pattern,i);
				if (last_node_end < i-bt_str.len){
					try childlist_and.append(Node.basic_init(.TXT_NODE, pattern[last_node_end..i-bt_str.len]));
					last_node_end = i-bt_str.len;
				}

				if (i > 0) {
					if (pattern[i-1] != ')' and pattern[i-1] != ']'){
						if (!std.mem.eql(u8, childlist_and.items[childlist_and.items.len-1].content, bt_str)){
							currnode = Node.basic_init(.TXT_NODE, bt_str);
							try childlist_and.append(currnode.?);
						}
					}
					if (pattern[i] == '?'){
						(childlist_and.items[childlist_and.items.len-1]).lower_lim = 0;
					} else if (pattern[i] == '*'){
						(childlist_and.items[childlist_and.items.len-1]).lower_lim = 0;
						(childlist_and.items[childlist_and.items.len-1]).upper_lim = MAX_INT;
					} else {
						(childlist_and.items[childlist_and.items.len-1]).upper_lim = MAX_INT;		
					}
					i += 1;
					last_node_end = i;
				}
			},
			'|' => {
				if (last_node_end < i){
					try childlist_and.append(Node.basic_init(.TXT_NODE, pattern[last_node_end..i]));
					last_node_end = i+1;
				}
				if (childlist_and.items.len > 1){
					const combnode = Node.init(.OP_NODE, "&", null, childlist_and.items, null, null);
					try childlist_or.append(combnode);
				} else {
					try childlist_or.append(childlist_and.items[0]);
				}
				childlist_and = std.ArrayList(Node).init(alloc);
				last_node_end = i+1;
				i += 1;
			},
			'.' => {
				if (i > 0 and pattern[i-1] != '\\'){
					if (last_node_end < i){
						try childlist_and.append(Node.basic_init(.TXT_NODE, pattern[last_node_end..i]));
					}
					currnode = Node.basic_init(.TXT_NODE, ".");
					try childlist_and.append(currnode.?);
				}
				last_node_end = i+1;
				i+=1;
			},
			'\\' => {
				esc_seq = true;
				i+=1;
			},
			else => {
				i+=1;
			}
		}
	}
	
	if (last_node_end < pattern.len){
		const lastnode = Node.basic_init(.TXT_NODE, pattern[last_node_end..]);
		try childlist_and.append(lastnode);
	}

	if (childlist_or.items.len > 0) {
		if (childlist_and.items.len > 1){
			const combnode = Node.init(.OP_NODE, "&", null, childlist_and.items, null, null);
			try childlist_or.append(combnode);
		}
		else {
			try childlist_or.append(childlist_and.items[0]);
		}
	}
	if (childlist_or.items.len == 0){
		if (childlist_and.items.len > 1){
			fullnode = Node.init(.OP_NODE, "&", null, childlist_and.items, null, null);
		} else {
			fullnode = childlist_and.items[0];
		}
	} else {
		if (childlist_or.items.len > 1) {
			fullnode = Node.init(.OP_NODE, "|", null, childlist_or.items, null, null);
		} else {
			fullnode = childlist_or.items[0];
		}
	}

	return ParsedTree.init(pattern, fullnode);
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

pub fn backtrack(string: []const u8, pos: usize) []const u8{
	if (string[pos-2] != '\\') {
		return string[pos-1..pos];
	} else {
		return string[pos-2..pos];
	}
}

pub fn operate(x1: bool, op: []const u8, x2: bool) bool{
	switch(op[0]){
		'&' => return (x1 and x2),
		'|' => return (x1 or x2)
	}
}
