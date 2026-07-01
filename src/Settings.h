#pragma once

#include <atomic>
#include <string>

namespace Settings {

using AtomicBool = std::atomic<bool>;
using AtomicInt = std::atomic<int>;
using AtomicFloat = std::atomic<float>;

extern AtomicBool bIsAppActive;
extern AtomicBool bShowMenu;
extern AtomicBool Cheatoff;

// ESP
extern AtomicBool bEnableESP;
extern AtomicBool bBoxESP;
extern AtomicBool bLineESP;
extern AtomicBool bDistanceESP;
extern AtomicBool bSkeletonESP;
extern AtomicBool bCountESP;
extern AtomicBool bMiniMapEsp;
extern AtomicBool bTurnEspRadius;
extern AtomicFloat espRadiusValue;
extern AtomicInt lineOrigin;
extern AtomicInt lineTarget;
extern AtomicFloat lineThickness;

// Aimbot
extern AtomicBool bAimEnable;
extern AtomicInt AimPart;
extern AtomicBool bAimLine;
extern AtomicBool bAimIndicator;
extern AtomicBool bAimDrawFov;
extern AtomicBool bVisibilityCheck;
extern AtomicFloat AimFov;
extern AtomicFloat AimSmooth;
extern AtomicBool bCrosshair;
extern AtomicBool FovEnable;
extern AtomicFloat FovVal;

// Movement
extern AtomicBool bSpeedHack;
extern AtomicBool bFlyEnable;
extern AtomicFloat FlySpeed;
extern AtomicFloat FlyJoySpeed;
extern AtomicBool bShowJoystick;
extern AtomicBool bCarhack;
extern AtomicFloat Carspeed;
extern AtomicBool bCarFly;
extern AtomicFloat carFlySpeed;

// Player scale
extern AtomicBool ScaleEnable;
extern AtomicBool BigHead;
extern AtomicBool BigChest;
extern AtomicBool BigBody;
extern AtomicFloat ScaleVal;

// Weapon
extern AtomicBool bInstantReload;
extern AtomicBool bFastShoot;

// Misc
extern AtomicBool bStreamerMode;
extern AtomicBool bEnableNotifications;
extern AtomicInt MenuTheme;
extern AtomicFloat uiScale;
extern AtomicInt selectedTab;
extern AtomicInt targetFPS;

// Teleport
extern AtomicBool bAutoTeleport;
extern AtomicInt selectedTeleport;

void Load();
void Save();

} // namespace Settings
