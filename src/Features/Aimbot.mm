#include "Aimbot.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"
#include "../Vector3.h"

#include <algorithm>
#include <cmath>
#include <cfloat>
#include <vector>

namespace AimbotFeature {

static PlayerEntity s_bestTarget{};
static bool s_hasTarget = false;

static const char *kAimParts[] = {"Head", "Chest", "Body"};

void Update(float screenW, float screenH) {
    s_hasTarget = false;
    if (!Settings::bAimEnable.load() || Settings::Cheatoff.load()) return;
    if (!UnityAPI::Initialize()) return;

    std::vector<PlayerEntity> players;
    Vector3 localPos = UnityAPI::GetTransformPosition(UnityAPI::GetLocalPlayerTransform());
    UnityAPI::ScanPlayers(players, localPos);

    float bestScore = FLT_MAX;
    float fov = Settings::AimFov.load();
    Vector2 center{screenW * 0.5f, screenH * 0.5f};

    for (const auto &p : players) {
        if (p.isLocal) continue;
        if (Settings::bVisibilityCheck.load() && !p.visible) continue;

        Vector3 targetPos = p.worldPos;
        int part = Settings::AimPart.load();
        if (part == 0) targetPos = p.headPos;
        else if (part == 1) targetPos = p.headPos; // chest approx

        Vector2 screenPos{};
        if (!UnityAPI::WorldToScreen(targetPos, screenPos, screenW, screenH)) continue;

        float dx = screenPos.x - center.x;
        float dy = screenPos.y - center.y;
        float dist = std::sqrt(dx * dx + dy * dy);
        if (dist > fov) continue;
        if (dist < bestScore) {
            bestScore = dist;
            s_bestTarget = p;
            s_hasTarget = true;
        }
    }
}

void Render(float screenW, float screenH) {
    (void)screenW;
    (void)screenH;
    if (!Settings::bAimEnable.load()) return;
    if (Settings::bAimDrawFov.load()) {
        // FOV circle drawn in MenuRenderer
    }
    if (Settings::bAimLine.load() && s_hasTarget) {
        // Target line drawn in MenuRenderer
    }
}

const PlayerEntity *GetBestTarget() {
    return s_hasTarget ? &s_bestTarget : nullptr;
}

const char **GetAimPartNames() {
    return const_cast<const char **>(kAimParts);
}

int GetAimPartCount() {
    return 3;
}

} // namespace AimbotFeature
