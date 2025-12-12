#include "core/Entity.hpp"
#include <algorithm>

Entity::Entity(const std::string& name) : m_name(name), m_active(true) {}

void Entity::addComponent(std::shared_ptr<Component> component) {
    m_components.push_back(component);
}

void Entity::removeComponent(const std::string& componentName) {
    m_components.erase(
        std::remove_if(m_components.begin(), m_components.end(),
                       [&componentName](const std::shared_ptr<Component>& comp) {
                           return comp->getName() == componentName;
                       }),
        m_components.end());
}

std::shared_ptr<Component> Entity::getComponent(const std::string& name) const {
    for (const auto& comp : m_components) {
        if (comp->getName() == name) {
            return comp;
        }
    }
    return nullptr;
}

void Entity::update(float deltaTime) {
    if (!m_active) return;
    for (auto& comp : m_components) {
        comp->update(deltaTime);
    }
}

Player::Player(const std::string& name, int health)
    : Entity(name), m_health(health), m_score(0) {}

void Player::takeDamage(int amount) {
    m_health -= amount;
    if (m_health < 0) m_health = 0;
}

void Player::heal(int amount) {
    m_health += amount;
}

void Player::addScore(int points) {
    m_score += points;
}

Enemy::Enemy(const std::string& name, int health, float aggroRange)
    : Entity(name), m_health(health), m_aggroRange(aggroRange) {}

void Enemy::takeDamage(int amount) {
    m_health -= amount;
    if (m_health < 0) m_health = 0;
}

bool Enemy::isInRange(float distance) const {
    return distance <= m_aggroRange;
}
