#pragma once
#include <string>

class Shape {
protected:
    float m_x, m_y;
    std::string m_color;

public:
    Shape(float x, float y, const std::string& color);
    virtual ~Shape() = default;
    virtual double area() const = 0;
    virtual double perimeter() const = 0;
    virtual void draw() const = 0;

    void setPosition(float x, float y);
    float getX() const { return m_x; }
    float getY() const { return m_y; }
};

class Circle : public Shape {
private:
    float m_radius;

public:
    Circle(float x, float y, float radius, const std::string& color);
    double area() const override;
    double perimeter() const override;
    void draw() const override;
    float getRadius() const { return m_radius; }
};

class Rectangle : public Shape {
private:
    float m_width, m_height;

public:
    Rectangle(float x, float y, float width, float height, const std::string& color);
    double area() const override;
    double perimeter() const override;
    void draw() const override;
    float getWidth() const { return m_width; }
    float getHeight() const { return m_height; }
};
