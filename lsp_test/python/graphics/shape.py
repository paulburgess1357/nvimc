"""Abstract shape classes for graphics system."""

from abc import ABC, abstractmethod
from dataclasses import dataclass
import math

from ..core import Component


@dataclass
class Color:
    """RGBA color representation."""

    r: float = 1.0
    g: float = 1.0
    b: float = 1.0
    a: float = 1.0

    def to_hex(self) -> str:
        """Convert to hex string."""
        return "#{:02x}{:02x}{:02x}".format(
            int(self.r * 255), int(self.g * 255), int(self.b * 255)
        )


@dataclass
class Vector2:
    """2D vector for positions and directions."""

    x: float = 0.0
    y: float = 0.0

    def __add__(self, other: "Vector2") -> "Vector2":
        return Vector2(self.x + other.x, self.y + other.y)

    def __sub__(self, other: "Vector2") -> "Vector2":
        return Vector2(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: float) -> "Vector2":
        return Vector2(self.x * scalar, self.y * scalar)

    def magnitude(self) -> float:
        """Get vector length."""
        return math.sqrt(self.x**2 + self.y**2)

    def normalized(self) -> "Vector2":
        """Get unit vector."""
        mag = self.magnitude()
        if mag == 0:
            return Vector2(0, 0)
        return Vector2(self.x / mag, self.y / mag)


class Shape(Component, ABC):
    """Abstract base class for renderable shapes.

    Test: gI on Shape should show implementations (Circle, Rectangle)
    """

    def __init__(self, position: Vector2 | None = None) -> None:
        super().__init__()
        self.position = position or Vector2()
        self.color = Color()
        self.visible = True

    @abstractmethod
    def area(self) -> float:
        """Calculate the area of the shape."""
        pass

    @abstractmethod
    def perimeter(self) -> float:
        """Calculate the perimeter of the shape."""
        pass

    @abstractmethod
    def contains_point(self, point: Vector2) -> bool:
        """Check if a point is inside the shape."""
        pass

    def update(self, delta_time: float) -> None:
        """Update shape state."""
        pass

    def render(self) -> None:
        """Render the shape."""
        if self.visible:
            self._draw()

    @abstractmethod
    def _draw(self) -> None:
        """Internal draw implementation."""
        pass


class Circle(Shape):
    """A circle shape."""

    def __init__(
        self, position: Vector2 | None = None, radius: float = 1.0
    ) -> None:
        super().__init__(position)
        self.radius = radius

    def area(self) -> float:
        """Calculate circle area: pi * r^2."""
        return math.pi * self.radius**2

    def perimeter(self) -> float:
        """Calculate circle circumference: 2 * pi * r."""
        return 2 * math.pi * self.radius

    def contains_point(self, point: Vector2) -> bool:
        """Check if point is inside circle."""
        distance = (point - self.position).magnitude()
        return distance <= self.radius

    def _draw(self) -> None:
        """Draw the circle."""
        print(f"Drawing circle at {self.position} with radius {self.radius}")


class Rectangle(Shape):
    """A rectangle shape."""

    def __init__(
        self,
        position: Vector2 | None = None,
        width: float = 1.0,
        height: float = 1.0,
    ) -> None:
        super().__init__(position)
        self.width = width
        self.height = height

    def area(self) -> float:
        """Calculate rectangle area: width * height."""
        return self.width * self.height

    def perimeter(self) -> float:
        """Calculate rectangle perimeter: 2 * (width + height)."""
        return 2 * (self.width + self.height)

    def contains_point(self, point: Vector2) -> bool:
        """Check if point is inside rectangle."""
        half_w = self.width / 2
        half_h = self.height / 2
        return (
            self.position.x - half_w <= point.x <= self.position.x + half_w
            and self.position.y - half_h <= point.y <= self.position.y + half_h
        )

    def _draw(self) -> None:
        """Draw the rectangle."""
        print(
            f"Drawing rectangle at {self.position} "
            f"with size {self.width}x{self.height}"
        )
