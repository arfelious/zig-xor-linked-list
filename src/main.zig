const std = @import("std");
const testing = std.testing;
const Node = struct {
    xor_addr: ?*Node,
    value: i32,
};
const LinkedList = struct {
    head: ?*Node,
    tail: ?*Node,
};
pub fn LinkedList_init() LinkedList {
    return LinkedList{
        .head = null,
        .tail = null,
    };
}
pub fn LinkedList_append(list: *LinkedList, node: *Node) void {
    const currentInt = @intFromPtr(node);
    const prevInt = @intFromPtr(list.tail);
    node.xor_addr = @ptrFromInt(prevInt ^ currentInt);
    if (list.head == null) {
        list.head = node;
    }
    if (list.tail != null) {
        const tailInt = @intFromPtr(list.tail);
        const next: *Node = @ptrFromInt(tailInt ^ currentInt);
        list.tail.?.xor_addr = @ptrFromInt(@intFromPtr(list.tail.?.xor_addr) ^ @intFromPtr(next));
    }
    list.tail = node;
}
pub fn LinkedList_prepend(list: *LinkedList, node: *Node) void {
    const currentInt = @intFromPtr(node);
    const nextInt = @intFromPtr(list.head);
    node.xor_addr = @ptrFromInt(nextInt);
    if (list.tail == null) {
        list.tail = node;
    }
    if (list.head != null) {
        list.head.?.xor_addr = @ptrFromInt(currentInt ^ @intFromPtr(list.head.?.xor_addr));
    }
    list.head = node;
}
pub fn print_list_start_end(list: *LinkedList, current_const: ?*Node, prev_const: ?*Node, is_reverse: bool) void {
    var current = current_const;
    var prev = prev_const;
    const goal: ?*Node = if (is_reverse) list.head else list.tail;
    while (current != null) {
        std.debug.print("Value: {d}\n", .{current.?.value});
        const prevInt: usize = @intFromPtr(prev);
        const currentInt: usize = @intFromPtr(current.?.xor_addr);
        const next: ?*Node = @ptrFromInt(prevInt ^ currentInt);
        prev = current;
        current = next;
        if (prev == goal) {
            break;
        }
    }
    std.debug.print("\n", .{});
}
pub fn print_list(list: *LinkedList) void {
    print_list_start_end(list, list.head, null, false);
}
pub fn print_list_reverse(list: *LinkedList) void {
    print_list_start_end(list, list.tail, list.tail, true);
}
test "test xor linked list" {
    var list = LinkedList_init();
    const test_values_append: [5]i32 = [_]i32{ 1, 2, 4, 8, 16 };
    const test_values_prepend: [5]i32 = [_]i32{ 2, 3, 5, 9, 17 };
    const test_values = test_values_append ++ test_values_prepend;
    var nodes: [10]Node = undefined;
    var i: u4 = 0;
    for (test_values) |test_value| {
        const curr = Node{ .xor_addr = null, .value = test_value };
        nodes[i] = curr;
        i += 1;
    }
    i = 0;
    for (&nodes) |*node| {
        if (i < 5) {
            LinkedList_append(&list, node);
        } else {
            LinkedList_prepend(&list, node);
        }
        i += 1;
    }
    var curr = list.head;
    var prev: ?*Node = null;
    i = 0;
    while (curr != null and prev != null) : (i += 1) {
        const nextInt = @intFromPtr(prev);
        const currInt = @intFromPtr(curr.?.xor_addr);
        const next: ?*Node = @ptrFromInt(nextInt ^ currInt);
        prev = curr;
        curr = next;
        var exp_value: i32 = @as(i32, 1) << (i - 5);
        if (i < 5) exp_value = (@as(i32, 1) << (4 - i)) + 1;
        try testing.expectEqual(exp_value, prev.?.value);
    }
}
