#include "core/Component.hpp"

TransformComponent::TransformComponent(float x, float y, float z)
    : m_x(x), m_y(y), m_z(z) {}

void TransformComponent::update(float deltaTime) {
    // Update logic here
}

std::string TransformComponent::getName() const {
    return "TransformComponent";
}

void TransformComponent::setPosition(float x, float y, float z) {
    m_x = x;
    m_y = y;
    m_z = z;
}

PhysicsComponent::PhysicsComponent(float mass)
    : m_velocityX(0), m_velocityY(0), m_velocityZ(0), m_mass(mass) {}

void PhysicsComponent::update(float deltaTime) {
    // Apply physics
}

std::string PhysicsComponent::getName() const {
    return "PhysicsComponent";
}

void PhysicsComponent::applyForce(float fx, float fy, float fz) {
    m_velocityX += fx / m_mass;
    m_velocityY += fy / m_mass;
    m_velocityZ += fz / m_mass;
}
