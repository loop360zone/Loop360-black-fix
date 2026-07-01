#include "Weapon.h"
#include "../Settings.h"
#include "../Unity/UnityAPI.h"

namespace WeaponFeature {

void Update() {
    if (Settings::Cheatoff.load()) return;
    if (!UnityAPI::Initialize()) return;

    if (Settings::bInstantReload.load()) {
        UnityAPI::ApplyInstantReload();
    }
    if (Settings::bFastShoot.load()) {
        UnityAPI::ApplyFastShoot(true);
    }
}

} // namespace WeaponFeature
