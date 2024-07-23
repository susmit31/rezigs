const std = @import("std");

pub fn main() void{
	for (0..5) |i| {
		switch(i){
			1, 2, 3 => {
				std.debug.print("Topper - ",.{});
				if (i == 1) {
					std.debug.print("First.\n",.{});
				} else if (i == 2) {
					std.debug.print("Second.\n", .{});
				} else if (i == 3) {
					std.debug.print("Third.\n",.{});
				}
			},
			else => {
				std.debug.print("Loser.\n",.{});
			}
		}
	}
}
