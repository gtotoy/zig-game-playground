export fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn MyGeneric(comptime T: type) type {
    return struct {
        t: T,
    };
}

const MyStruct = struct {
    s: u23,
};

export var ms: MyStruct = .{ .s = 7 };

const MyGenericInt = MyGeneric(u32);

export var mgi = MyGenericInt { .t = 77 };

export fn foo() u32 {
    var as = MyGeneric(u32) { .t = 42 };
    return as.t;
}