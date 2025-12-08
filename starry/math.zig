//! Math stuff.

/// A rectangle of 2D variety
pub fn Rect2D(comptime T: type) type {
    return struct {
        pos: @Vector(2, T),
        size: @Vector(2, T),
    };
}
