#include "PlayerScale.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"

namespace PlayerScaleFeature {

void Update() {
    if (!Settings::ScaleEnable.load() || Settings::Cheatoff.load()) return;
    if (!UnityAPI::Initialize()) return;

    float scale = Settings::ScaleVal.load();
    float head = Settings::BigHead.load() ? scale : 1.f;
    float chest = Settings::BigChest.load() ? scale : 1.f;
    float body = Settings::BigBody.load() ? scale : 1.f;
    UnityAPI::ApplyPlayerScale(head, chest, body);
}

} // namespace PlayerScaleFeature
