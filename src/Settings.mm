#include "Settings.h"
#import <Foundation/Foundation.h>

namespace Settings {

AtomicBool bIsAppActive{true};
AtomicBool bShowMenu{false};
AtomicBool Cheatoff{false};

AtomicBool bEnableESP{false};
AtomicBool bBoxESP{true};
AtomicBool bLineESP{true};
AtomicBool bDistanceESP{true};
AtomicBool bSkeletonESP{false};
AtomicBool bCountESP{true};
AtomicBool bMiniMapEsp{false};
AtomicBool bTurnEspRadius{false};
AtomicFloat espRadiusValue{150.f};
AtomicInt lineOrigin{0};
AtomicInt lineTarget{0};
AtomicFloat lineThickness{1.5f};

AtomicBool bAimEnable{false};
AtomicInt AimPart{0};
AtomicBool bAimLine{true};
AtomicBool bAimIndicator{true};
AtomicBool bAimDrawFov{true};
AtomicBool bVisibilityCheck{true};
AtomicFloat AimFov{90.f};
AtomicFloat AimSmooth{5.f};
AtomicBool bCrosshair{false};
AtomicBool FovEnable{false};
AtomicFloat FovVal{90.f};

AtomicBool bSpeedHack{false};
AtomicBool bFlyEnable{false};
AtomicFloat FlySpeed{8.f};
AtomicFloat FlyJoySpeed{5.f};
AtomicBool bShowJoystick{true};
AtomicBool bCarhack{false};
AtomicFloat Carspeed{1.5f};
AtomicBool bCarFly{false};
AtomicFloat carFlySpeed{10.f};

AtomicBool ScaleEnable{false};
AtomicBool BigHead{false};
AtomicBool BigChest{false};
AtomicBool BigBody{false};
AtomicFloat ScaleVal{1.5f};

AtomicBool bInstantReload{false};
AtomicBool bFastShoot{false};

AtomicBool bStreamerMode{false};
AtomicBool bEnableNotifications{true};
AtomicInt MenuTheme{3};
AtomicFloat uiScale{1.f};
AtomicInt selectedTab{0};
AtomicInt targetFPS{60};

AtomicBool bAutoTeleport{false};
AtomicInt selectedTeleport{0};

static NSUserDefaults *Defaults() {
    return [[NSUserDefaults alloc] initWithSuiteName:@"com.statescript.hack"];
}

static void LoadBool(const char *key, AtomicBool &out, bool def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v boolValue] : def);
}

static void LoadInt(const char *key, AtomicInt &out, int def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v intValue] : def);
}

static void LoadFloat(const char *key, AtomicFloat &out, float def) {
    id v = [Defaults() objectForKey:[NSString stringWithUTF8String:key]];
    out.store(v ? [v floatValue] : def);
}

void Load() {
    LoadBool("bEnableESP", bEnableESP, false);
    LoadBool("bBoxESP", bBoxESP, true);
    LoadBool("bLineESP", bLineESP, true);
    LoadBool("bDistanceESP", bDistanceESP, true);
    LoadBool("bSkeletonESP", bSkeletonESP, false);
    LoadBool("bCountESP", bCountESP, true);
    LoadBool("bMiniMapEsp", bMiniMapEsp, false);
    LoadBool("bTurnEspRadius", bTurnEspRadius, false);
    LoadFloat("espRadiusValue", espRadiusValue, 150.f);
    LoadInt("lineOrigin", lineOrigin, 0);
    LoadInt("lineTarget", lineTarget, 0);
    LoadFloat("lineThickness", lineThickness, 1.5f);

    LoadBool("AimEnable", bAimEnable, false);
    LoadInt("AimPart", AimPart, 0);
    LoadBool("AimLine", bAimLine, true);
    LoadBool("AimInd", bAimIndicator, true);
    LoadBool("AimDrawFov", bAimDrawFov, true);
    LoadBool("VisCheck", bVisibilityCheck, true);
    LoadFloat("AimFov", AimFov, 90.f);
    LoadFloat("AimSmooth", AimSmooth, 5.f);
    LoadBool("Crosshair", bCrosshair, false);
    LoadBool("FovEnable", FovEnable, false);
    LoadFloat("FovVal", FovVal, 90.f);

    LoadBool("SpeedHack", bSpeedHack, false);
    LoadBool("FlyEnable", bFlyEnable, false);
    LoadFloat("FlySpeed", FlySpeed, 8.f);
    LoadFloat("FlyJoySpeed", FlyJoySpeed, 5.f);
    LoadBool("bShowJoystick", bShowJoystick, true);
    LoadBool("bCarhack", bCarhack, false);
    LoadFloat("Carspeed", Carspeed, 1.5f);
    LoadBool("bCarFly", bCarFly, false);
    LoadFloat("carFlySpeed", carFlySpeed, 10.f);

    LoadBool("ScaleEnable", ScaleEnable, false);
    LoadBool("BigHead", BigHead, false);
    LoadBool("BigChest", BigChest, false);
    LoadBool("BigBody", BigBody, false);
    LoadFloat("ScaleVal", ScaleVal, 1.5f);

    LoadBool("InstReload", bInstantReload, false);
    LoadBool("FastShoot", bFastShoot, false);

    LoadBool("StreamerMode", bStreamerMode, false);
    LoadBool("NotifEnable", bEnableNotifications, true);
    LoadInt("MenuTheme", MenuTheme, 3);
    LoadFloat("uiScale", uiScale, 1.f);
    LoadInt("selectedTab", selectedTab, 0);
    LoadInt("targetFPS", targetFPS, 60);
    LoadBool("bAutoTeleport", bAutoTeleport, false);
    LoadInt("selectedTeleport", selectedTeleport, 0);
}

static void SaveBool(const char *key, AtomicBool &v) {
    [Defaults() setBool:v.load() forKey:[NSString stringWithUTF8String:key]];
}

static void SaveInt(const char *key, AtomicInt &v) {
    [Defaults() setInteger:v.load() forKey:[NSString stringWithUTF8String:key]];
}

static void SaveFloat(const char *key, AtomicFloat &v) {
    [Defaults() setFloat:v.load() forKey:[NSString stringWithUTF8String:key]];
}

void Save() {
    SaveBool("bEnableESP", bEnableESP);
    SaveBool("bBoxESP", bBoxESP);
    SaveBool("bLineESP", bLineESP);
    SaveBool("bDistanceESP", bDistanceESP);
    SaveBool("bSkeletonESP", bSkeletonESP);
    SaveBool("bCountESP", bCountESP);
    SaveBool("bMiniMapEsp", bMiniMapEsp);
    SaveBool("bTurnEspRadius", bTurnEspRadius);
    SaveFloat("espRadiusValue", espRadiusValue);
    SaveInt("lineOrigin", lineOrigin);
    SaveInt("lineTarget", lineTarget);
    SaveFloat("lineThickness", lineThickness);

    SaveBool("AimEnable", bAimEnable);
    SaveInt("AimPart", AimPart);
    SaveBool("AimLine", bAimLine);
    SaveBool("AimInd", bAimIndicator);
    SaveBool("AimDrawFov", bAimDrawFov);
    SaveBool("VisCheck", bVisibilityCheck);
    SaveFloat("AimFov", AimFov);
    SaveFloat("AimSmooth", AimSmooth);
    SaveBool("Crosshair", bCrosshair);
    SaveBool("FovEnable", FovEnable);
    SaveFloat("FovVal", FovVal);

    SaveBool("SpeedHack", bSpeedHack);
    SaveBool("FlyEnable", bFlyEnable);
    SaveFloat("FlySpeed", FlySpeed);
    SaveFloat("FlyJoySpeed", FlyJoySpeed);
    SaveBool("bShowJoystick", bShowJoystick);
    SaveBool("bCarhack", bCarhack);
    SaveFloat("Carspeed", Carspeed);
    SaveBool("bCarFly", bCarFly);
    SaveFloat("carFlySpeed", carFlySpeed);

    SaveBool("ScaleEnable", ScaleEnable);
    SaveBool("BigHead", BigHead);
    SaveBool("BigChest", BigChest);
    SaveBool("BigBody", BigBody);
    SaveFloat("ScaleVal", ScaleVal);

    SaveBool("InstReload", bInstantReload);
    SaveBool("FastShoot", bFastShoot);

    SaveBool("StreamerMode", bStreamerMode);
    SaveBool("NotifEnable", bEnableNotifications);
    SaveInt("MenuTheme", MenuTheme);
    SaveFloat("uiScale", uiScale);
    SaveInt("selectedTab", selectedTab);
    SaveInt("targetFPS", targetFPS);
    SaveBool("bAutoTeleport", bAutoTeleport);
    SaveInt("selectedTeleport", selectedTeleport);

    [Defaults() synchronize];
}

} // namespace Settings
