"""Mathematical utility functions."""

import math
from typing import TypeVar, Sequence

T = TypeVar("T", int, float)


def clamp(value: T, min_val: T, max_val: T) -> T:
    """Clamp a value between min and max.

    Args:
        value: The value to clamp.
        min_val: Minimum allowed value.
        max_val: Maximum allowed value.

    Returns:
        The clamped value.
    """
    return max(min_val, min(max_val, value))


def lerp(a: float, b: float, t: float) -> float:
    """Linear interpolation between two values.

    Args:
        a: Start value.
        b: End value.
        t: Interpolation factor (0.0 to 1.0).

    Returns:
        Interpolated value.
    """
    return a + (b - a) * t


def inverse_lerp(a: float, b: float, value: float) -> float:
    """Inverse linear interpolation.

    Args:
        a: Start value.
        b: End value.
        value: Value to find t for.

    Returns:
        The t value that would produce the given value in lerp.
    """
    if a == b:
        return 0.0
    return (value - a) / (b - a)


class MathUtils:
    """Collection of math utility functions.

    Test: hover over methods to see docstrings
    """

    @staticmethod
    def deg_to_rad(degrees: float) -> float:
        """Convert degrees to radians."""
        return degrees * math.pi / 180.0

    @staticmethod
    def rad_to_deg(radians: float) -> float:
        """Convert radians to degrees."""
        return radians * 180.0 / math.pi

    @staticmethod
    def smoothstep(edge0: float, edge1: float, x: float) -> float:
        """Smooth Hermite interpolation.

        Args:
            edge0: Lower edge of range.
            edge1: Upper edge of range.
            x: Input value.

        Returns:
            Smoothly interpolated value between 0 and 1.
        """
        t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
        return t * t * (3.0 - 2.0 * t)

    @staticmethod
    def smootherstep(edge0: float, edge1: float, x: float) -> float:
        """Smoother (Ken Perlin's) interpolation."""
        t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
        return t * t * t * (t * (t * 6.0 - 15.0) + 10.0)

    @staticmethod
    def remap(
        value: float,
        in_min: float,
        in_max: float,
        out_min: float,
        out_max: float,
    ) -> float:
        """Remap a value from one range to another.

        Args:
            value: Input value.
            in_min: Input range minimum.
            in_max: Input range maximum.
            out_min: Output range minimum.
            out_max: Output range maximum.

        Returns:
            Value mapped to output range.
        """
        t = inverse_lerp(in_min, in_max, value)
        return lerp(out_min, out_max, t)

    @staticmethod
    def average(values: Sequence[float]) -> float:
        """Calculate average of values."""
        if not values:
            return 0.0
        return sum(values) / len(values)

    @staticmethod
    def distance(x1: float, y1: float, x2: float, y2: float) -> float:
        """Calculate Euclidean distance between two points."""
        return math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)

    @staticmethod
    def normalize_angle(angle: float) -> float:
        """Normalize angle to range [-pi, pi]."""
        while angle > math.pi:
            angle -= 2 * math.pi
        while angle < -math.pi:
            angle += 2 * math.pi
        return angle
