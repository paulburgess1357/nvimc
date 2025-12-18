"""Renderer for managing and drawing shapes."""

from typing import Callable
from ..core import Entity
from .shape import Shape, Vector2, Color


class RenderStats:
    """Statistics for render performance."""

    def __init__(self) -> None:
        self.draw_calls: int = 0
        self.shapes_rendered: int = 0
        self.frame_count: int = 0

    def reset(self) -> None:
        """Reset per-frame stats."""
        self.draw_calls = 0
        self.shapes_rendered = 0

    def new_frame(self) -> None:
        """Start a new frame."""
        self.reset()
        self.frame_count += 1


class Renderer:
    """Manages rendering of entities and shapes.

    Test LSP:
    - gr on render_entity should show references
    - gy on Shape should go to type definition
    """

    def __init__(self, width: int = 800, height: int = 600) -> None:
        self.width = width
        self.height = height
        self.clear_color = Color(0.1, 0.1, 0.1, 1.0)
        self.stats = RenderStats()
        self._entities: list[Entity] = []
        self._post_process: list[Callable[[], None]] = []

    def add_entity(self, entity: Entity) -> None:
        """Add an entity to be rendered."""
        if entity not in self._entities:
            self._entities.append(entity)

    def remove_entity(self, entity: Entity) -> bool:
        """Remove an entity from rendering."""
        if entity in self._entities:
            self._entities.remove(entity)
            return True
        return False

    def add_post_process(self, effect: Callable[[], None]) -> None:
        """Add a post-processing effect."""
        self._post_process.append(effect)

    def clear(self) -> None:
        """Clear the screen with clear color."""
        print(f"Clearing screen with color {self.clear_color.to_hex()}")

    def render_entity(self, entity: Entity) -> None:
        """Render a single entity and its shape components."""
        if not entity.active:
            return

        shapes = entity.get_components(Shape)
        for shape in shapes:
            if shape.visible and shape.enabled:
                shape.render()
                self.stats.shapes_rendered += 1
                self.stats.draw_calls += 1

    def render_all(self) -> None:
        """Render all entities."""
        self.stats.new_frame()
        self.clear()

        for entity in self._entities:
            self.render_entity(entity)

        # Apply post-processing
        for effect in self._post_process:
            effect()
            self.stats.draw_calls += 1

    def render_shape_at(self, shape: Shape, position: Vector2) -> None:
        """Render a shape at a specific position."""
        original_pos = shape.position
        shape.position = position
        shape.render()
        shape.position = original_pos
        self.stats.draw_calls += 1

    def get_entity_at(self, point: Vector2) -> Entity | None:
        """Find entity at screen position."""
        for entity in reversed(self._entities):
            shapes = entity.get_components(Shape)
            for shape in shapes:
                if shape.contains_point(point):
                    return entity
        return None

    def __repr__(self) -> str:
        return f"Renderer({self.width}x{self.height}, entities={len(self._entities)})"
