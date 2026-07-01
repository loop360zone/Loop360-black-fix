#include "Movement.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"

namespace MovementFeature {

void Update(float dt) {
    (void)dt;
    if (Settings::Cheatoff.load()) return;
    if (!UnityAPI::Initialize()) return;

    if (Settings::bSpeedHack.load()) {
        UnityAPI::ApplySpeedMultiplier(2.0f);
    }

    if (Settings::bFlyEnable.load()) {
        Vector3 dir{0.f, 1.f, 0.f};
        UnityAPI::ApplyFly(dir, Settings::FlySpeed.load());
    }

    if (Settings::bCarhack.load()) {
        UnityAPI::ApplyCarSpeed(Settings::Carspeed.load());
    }

    if (Settings::bCarFly.load()) {
        UnityAPI::ApplyCarFly(Settings::carFlySpeed.load());
    }
}

} // namespace MovementFeature
