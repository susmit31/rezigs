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

		if (self.variety == .OP_NODE){
			todo();
		} else {
			for (self.children) |child|{
				res = operate(res, child.eval(), content);
			}
		}

		return res;
	}
}
