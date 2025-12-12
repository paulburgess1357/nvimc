#pragma once
#include <memory>
#include <vector>
#include <string>
#include "Component.hpp"

class Entity {
private:
    std::string m_name;
    std::vector<std::shared_ptr<Component>> m_components;
    bool m_active;

public:
    Entity(const std::string& name);
    virtual ~Entity() = default;

    void addComponent(std::shared_ptr<Component> component);
    void removeComponent(const std::string& componentName);
    std::shared_ptr<Component> getComponent(const std::string& name) const;

    void update(float deltaTime);
    void setActive(bool active) { m_active = active; }
    bool isActive() const { return m_active; }
    const std::string& getName() const { return m_name; }
};

class Player : public Entity {
private:
    int m_health;
    int m_score;

public:
    Player(const std::string& name, int health);
    void takeDamage(int amount);
    void heal(int amount);
    void addScore(int points);
    int getHealth() const { return m_health; }
    int getScore() const { return m_score; }
};

class Enemy : public Entity {
private:
    int m_health;
    float m_aggroRange;

public:
    Enemy(const std::string& name, int health, float aggroRange);
    void takeDamage(int amount);
    bool isInRange(float distance) const;
    int getHealth() const { return m_health; }
};
