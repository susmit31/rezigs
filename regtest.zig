const std = @import("std");
const re = @import("./newstructs.zig");
const stdout = std.io.getStdOut();
pub fn main() !void{
	const pattern: []const u8 = "hello* world|bye? world|sup+ world";
//	const pattern: []const u8 = "hello|bye|sup";
//	const pattern: []const u8 = "phi(l-)+(oxf|camb|stan)-.*(\\.)?(JPE?G|jpe?g)";
//	const pattern: []const u8 = "hello.\\wworld";
	const parsed = try re.parse_regex(pattern);

	try stdout.writer().print("Tree for pattern `{s}`:\n", .{pattern});
	try parsed.print();
	try stdout.writer().print("\n\n",.{});
}
