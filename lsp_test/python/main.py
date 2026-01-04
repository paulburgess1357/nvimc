#!/usr/bin/env python3
"""Main entry point demonstrating the entity-component system.

LSP Test Instructions:
- gd on any import to jump to definition
- gr on Entity to see all references
- gI on Shape to see implementations
- K on any function to see docstring
- leader-ss for document symbols
"""

from core import Entity
from graphics import Shape, Circle, Rectangle, Renderer
from graphics.shape import Vector2, Color
from utils import Logger, LogLevel, MathUtils, lerp


def create_sample_scene() -> tuple[Renderer, list[Entity]]:
    """Create a sample scene with shapes.

    Returns:
        Tuple of (renderer, list of entities).
    """
    logger = Logger.get_instance()
    logger.info("Creating sample scene")

    renderer = Renderer(1920, 1080)
    entities: list[Entity] = []

    # Create player entity with circle shape
    player = Entity("Player")
    player_shape = Circle(Vector2(100, 100), radius=25)
    player_shape.color = Color(0.2, 0.8, 0.2)
    player.add_component(player_shape)
    entities.append(player)
    renderer.add_entity(player)

    # Create enemy entities
    for i in range(3):
        enemy = Entity(f"Enemy_{i}")
        x = lerp(200, 600, i / 2)
        enemy_shape = Rectangle(Vector2(x, 300), width=30, height=30)
        enemy_shape.color = Color(0.8, 0.2, 0.2)
        enemy.add_component(enemy_shape)
        entities.append(enemy)
        renderer.add_entity(enemy)

    # Create obstacle
    obstacle = Entity("Obstacle")
    obstacle_shape = Rectangle(Vector2(400, 200), width=100, height=20)
    obstacle_shape.color = Color(0.5, 0.5, 0.5)
    obstacle.add_component(obstacle_shape)
    entities.append(obstacle)
    renderer.add_entity(obstacle)

    logger.info(f"Created {len(entities)} entities")
    return renderer, entities


def game_loop(renderer: Renderer, entities: list[Entity]) -> None:
    """Run a simple game loop.

    Args:
        renderer: The renderer instance.
        entities: List of entities to update.
    """
    logger = Logger.get_instance()
    delta_time = 1.0 / 60.0  # 60 FPS

    logger.info("Starting game loop")

    for frame in range(3):  # Just 3 frames for demo
        # Update all entities
        for entity in entities:
            entity.update(delta_time)

        # Render
        renderer.render_all()

        # Log stats
        stats = renderer.stats
        logger.debug(
            f"Frame {stats.frame_count}: "
            f"{stats.shapes_rendered} shapes, "
            f"{stats.draw_calls} draw calls"
        )

    logger.info("Game loop finished")


def demonstrate_math_utils() -> None:
    """Show MathUtils functionality."""
    logger = Logger.get_instance()

    # Test various math functions
    angle_deg = 45.0
    angle_rad = MathUtils.deg_to_rad(angle_deg)
    logger.info(f"{angle_deg} degrees = {angle_rad:.4f} radians")

    # Smoothstep interpolation
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        smooth = MathUtils.smoothstep(0, 1, t)
        logger.debug(f"smoothstep({t}) = {smooth:.4f}")

    # Distance calculation
    dist = MathUtils.distance(0, 0, 3, 4)
    logger.info(f"Distance from origin to (3,4) = {dist}")


def main() -> None:
    """Main function."""
    # Setup logging
    logger = Logger("game", LogLevel.DEBUG)
    Logger.set_instance(logger)

    logger.info("=== LSP Test Project ===")

    # Create and run scene
    renderer, entities = create_sample_scene()
    game_loop(renderer, entities)

    # Math demo
    logger.info("--- Math Utils Demo ---")
    demonstrate_math_utils()

    # Test entity lookup
    logger.info("--- Entity Tests ---")
    player = entities[0]
    shape = player.get_component(Shape)
    if shape:
        logger.info(f"Player shape area: {shape.area():.2f}")
        logger.info(f"Player shape perimeter: {shape.perimeter():.2f}")

    # Check point containment
    test_point = Vector2(100, 100)
    hit_entity = renderer.get_entity_at(test_point)
    if hit_entity:
        logger.info(f"Entity at {test_point}: {hit_entity.name}")

    logger.info("=== Done ===")


if __name__ == "__main__":
    main()
