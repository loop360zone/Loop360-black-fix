#include "ESP.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"
#include "../Vector3.h"

#include <algorithm>
#include <vector>

namespace ESPFeature {

static std::vector<PlayerEntity> s_players;

void Update(float screenW, float screenH) {
    (void)screenW;
    (void)screenH;
    if (!Settings::bEnableESP.load() || Settings::Cheatoff.load()) return;
    if (!UnityAPI::Initialize()) return;

    Vector3 localPos = UnityAPI::GetTransformPosition(UnityAPI::GetLocalPlayerTransform());
    UnityAPI::ScanPlayers(s_players, localPos);

    if (Settings::bTurnEspRadius.load()) {
        float radius = Settings::espRadiusValue.load();
        s_players.erase(
            std::remove_if(s_players.begin(), s_players.end(),
                [radius, &localPos](const PlayerEntity &p) {
                    return p.distance > radius;
                }),
            s_players.end());
    }
}

void Render(float screenW, float screenH) {
    if (!Settings::bEnableESP.load() || Settings::Cheatoff.load()) return;

    for (const auto &player : s_players) {
        if (player.isLocal) continue;

        Vector2 screen{};
        if (!UnityAPI::WorldToScreen(player.worldPos, screen, screenW, screenH)) continue;

        (void)screen;
        // Draw calls handled in MenuRenderer overlay pass (ImDrawList)
    }
}

} // namespace ESPFeature
