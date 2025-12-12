#include "graphics/Shape.hpp"
#include "utils/MathUtils.hpp"
#include "utils/Logger.hpp"

Shape::Shape(float x, float y, const std::string& color)
    : m_x(x), m_y(y), m_color(color) {}

void Shape::setPosition(float x, float y) {
    m_x = x;
    m_y = y;
}

Circle::Circle(float x, float y, float radius, const std::string& color)
    : Shape(x, y, color), m_radius(radius) {}

double Circle::area() const {
    return MathUtils::PI * m_radius * m_radius;
}

double Circle::perimeter() const {
    return 2 * MathUtils::PI * m_radius;
}

void Circle::draw() const {
    Logger::getInstance().debug("Drawing circle at (" + std::to_string(m_x) + ", " +
                                std::to_string(m_y) + ")");
}

Rectangle::Rectangle(float x, float y, float width, float height, const std::string& color)
    : Shape(x, y, color), m_width(width), m_height(height) {}

double Rectangle::area() const {
    return m_width * m_height;
}

double Rectangle::perimeter() const {
    return 2 * (m_width + m_height);
}

void Rectangle::draw() const {
    Logger::getInstance().debug("Drawing rectangle at (" + std::to_string(m_x) + ", " +
                                std::to_string(m_y) + ")");
}
