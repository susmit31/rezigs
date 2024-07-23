const std = @import("std");
const stdout = std.io.getStdOut();

pub fn main() !void{
	var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const alloc = gpa.allocator();
	var list = std.ArrayList(i32).init(alloc);
	try list.append(32);
	try list.append(27);
	try list.append(31);
	try list.append(28);
	try list.append(45);
	for (list.items) |mem|{
		try stdout.writer().print("Name: {d}\n", .{mem});
	}
}
