#include "core/Component.hpp"
#include "core/Entity.hpp"
#include "graphics/Renderer.hpp"
#include "graphics/Shape.hpp"
#include "utils/Logger.hpp"
#include "utils/MathUtils.hpp"
#include <iostream>
#include <memory>

int main() {
    Logger::getInstance().setMinLevel(LogLevel::DEBUG);
    Logger::getInstance().info("Application started");

    // Create entities
    auto player = std::make_shared<Player>("Hero", 100);
    auto transform = std::make_shared<TransformComponent>(0, 0, 0);
    auto physics = std::make_shared<PhysicsComponent>(75.0f);

    player->addComponent(transform);
    player->addComponent(physics);

    throw std::runtime_error("hi");

    auto enemy = std::make_shared<Enemy>("Goblin", 50, 10.0f);

    // Test entity system
    player->update(0.016f);
    player->takeDamage(20);
    player->addScore(100);

    Logger::getInstance().info("Player health: " + std::to_string(player->getHealth()));
    Logger::getInstance().info("Player score: " + std::to_string(player->getScore()));

    // Test graphics system
    Renderer renderer(800, 600);

    auto circle = std::make_shared<Circle>(100, 100, 50, "red");
    auto rectangle = std::make_shared<Rectangle>(200, 200, 100, 75, "blue");

    renderer.addShape(circle);
    renderer.addShape(rectangle);
    renderer.render();

    // Test math utils
    double dist = MathUtils::distance(0, 0, 3, 4);
    Logger::getInstance().info("Distance: " + std::to_string(dist));

    double clamped = MathUtils::clamp(15.0, 0.0, 10.0);
    Logger::getInstance().info("Clamped value: " + std::to_string(clamped));

    Logger::getInstance().info("Application ended");
    return 0;
}
