#pragma once

#include "../Vector3.h"

struct TeleportLocation {
    const char *id;
    Vector3 position;
};

namespace TeleportFeature {
const TeleportLocation *GetLocations(int &count);
void TeleportTo(int index);
void UpdateAuto();
}
