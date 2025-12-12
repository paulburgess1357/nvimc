#pragma once

namespace MathUtils {
    constexpr double PI = 3.14159265358979323846;

    double distance(double x1, double y1, double x2, double y2);
    double clamp(double value, double min, double max);
    double lerp(double a, double b, double t);
    int randomInt(int min, int max);
}
