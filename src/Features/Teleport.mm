#include "Teleport.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"

namespace TeleportFeature {

static const TeleportLocation kLocations[] = {
    {"Police", {0.f, 0.f, 0.f}},
    {"Armory", {0.f, 0.f, 0.f}},
    {"Vehicle Shop", {0.f, 0.f, 0.f}},
    {"Food", {0.f, 0.f, 0.f}},
    {"Clothes", {0.f, 0.f, 0.f}},
    {"Clan", {0.f, 0.f, 0.f}},
    {"Event - Military", {0.f, 0.f, 0.f}},
    {"Event - Port", {0.f, 0.f, 0.f}},
    {"Event - Spray", {0.f, 0.f, 0.f}},
    {"Jobs - Point", {0.f, 0.f, 0.f}},
    {"Jobs - AutoFarm", {0.f, 0.f, 0.f}},
};

const TeleportLocation *GetLocations(int &count) {
    count = (int)(sizeof(kLocations) / sizeof(kLocations[0]));
    return kLocations;
}

void TeleportTo(int index) {
    int count = 0;
    GetLocations(count);
    if (index < 0 || index >= count) return;
    if (!UnityAPI::Initialize()) return;

    void *local = UnityAPI::GetLocalPlayerTransform();
    if (!local) return;
    UnityAPI::SetTransformPosition(local, kLocations[index].position);
    UnityAPI::Physics_SyncTransforms();
}

void UpdateAuto() {
    if (!Settings::bAutoTeleport.load() || Settings::Cheatoff.load()) return;
    TeleportTo(Settings::selectedTeleport.load());
}

} // namespace TeleportFeature
