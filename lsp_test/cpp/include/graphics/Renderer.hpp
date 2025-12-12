#pragma once
#include <vector>
#include <memory>
#include "Shape.hpp"

class Renderer {
private:
    std::vector<std::shared_ptr<Shape>> m_shapes;
    int m_width, m_height;

public:
    Renderer(int width, int height);
    void addShape(std::shared_ptr<Shape> shape);
    void removeShape(std::shared_ptr<Shape> shape);
    void render() const;
    void clear();
    int getWidth() const { return m_width; }
    int getHeight() const { return m_height; }
};
