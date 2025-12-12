#pragma once
#include <string>

class Component {
public:
    virtual ~Component() = default;
    virtual void update(float deltaTime) = 0;
    virtual std::string getName() const = 0;
};

class TransformComponent : public Component {
private:
    float m_x, m_y, m_z;

public:
    TransformComponent(float x, float y, float z);
    void update(float deltaTime) override;
    std::string getName() const override;
    void setPosition(float x, float y, float z);
    float getX() const { return m_x; }
    float getY() const { return m_y; }
    float getZ() const { return m_z; }
};

class PhysicsComponent : public Component {
private:
    float m_velocityX, m_velocityY, m_velocityZ;
    float m_mass;

public:
    PhysicsComponent(float mass);
    void update(float deltaTime) override;
    std::string getName() const override;
    void applyForce(float fx, float fy, float fz);
    float getMass() const { return m_mass; }
};
