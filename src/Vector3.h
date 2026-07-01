#pragma once

#include "SSIncludes.h"

struct Vector3 {
    float x = 0.f, y = 0.f, z = 0.f;

    Vector3() = default;
    Vector3(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}

    Vector3 operator+(const Vector3 &o) const { return {x + o.x, y + o.y, z + o.z}; }
    Vector3 operator-(const Vector3 &o) const { return {x - o.x, y - o.y, z - o.z}; }
    Vector3 operator*(float s) const { return {x * s, y * s, z * s}; }

    float magnitude() const { return std::sqrt(x * x + y * y + z * z); }
    float distance(const Vector3 &o) const { return (*this - o).magnitude(); }
};

struct Vector2 {
    float x = 0.f, y = 0.f;
};

struct PlayerEntity {
    void *transform = nullptr;
    void *gameObject = nullptr;
    Vector3 worldPos{};
    Vector3 headPos{};
    float distance = 0.f;
    bool visible = false;
    bool isLocal = false;
    bool inVehicle = false;
    int teamId = 0;
};
