#include "graphics/Renderer.hpp"
#include "utils/Logger.hpp"
#include <algorithm>

Renderer::Renderer(int width, int height) : m_width(width), m_height(height) {}

void Renderer::addShape(std::shared_ptr<Shape> shape) {
    m_shapes.push_back(shape);
    Logger::getInstance().info("Shape added to renderer");
}

void Renderer::removeShape(std::shared_ptr<Shape> shape) {
    m_shapes.erase(std::remove(m_shapes.begin(), m_shapes.end(), shape), m_shapes.end());
}

void Renderer::render() const {
    Logger::getInstance().info("Rendering " + std::to_string(m_shapes.size()) + " shapes");
    for (const auto& shape : m_shapes) {
        shape->draw();
    }
}

void Renderer::clear() {
    m_shapes.clear();
}
