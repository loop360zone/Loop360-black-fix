#include "MenuRenderer.h"
#include "Localization.h"
#include "Themes.h"
#include "../Settings.h"
#include "../Features/Teleport.h"

#include "imgui.h"

namespace MenuRenderer {

static Settings::AtomicBool s_configsLoaded{false};

static bool AtomicCheckbox(const char *label, Settings::AtomicBool &v) {
    bool local = v.load();
    if (ImGui::Checkbox(label, &local)) {
        v.store(local);
        Settings::Save();
        return true;
    }
    return false;
}

static bool AtomicSliderFloat(const char *label, Settings::AtomicFloat &v, float minV, float maxV) {
    float local = v.load();
    if (ImGui::SliderFloat(label, &local, minV, maxV)) {
        v.store(local);
        Settings::Save();
        return true;
    }
    return false;
}

static bool AtomicSliderInt(const char *label, Settings::AtomicInt &v, int minV, int maxV) {
    int local = v.load();
    if (ImGui::SliderInt(label, &local, minV, maxV)) {
        v.store(local);
        Settings::Save();
        return true;
    }
    return false;
}

static void RenderGeneralTab() {
    ImGui::Text("%s", Localization::Get("cheats_by"));
    ImGui::Separator();

    AtomicCheckbox(Localization::Get("enable_esp"), Settings::bEnableESP);
    AtomicCheckbox(Localization::Get("enable_aimbot"), Settings::bAimEnable);
    AtomicCheckbox(Localization::Get("speed_hack"), Settings::bSpeedHack);
    AtomicCheckbox(Localization::Get("fly_hacks"), Settings::bFlyEnable);

    if (Settings::bFlyEnable.load()) {
        AtomicSliderFloat(Localization::Get("fly_speed"), Settings::FlySpeed, 1.f, 30.f);
        AtomicSliderFloat("Joystick Speed", Settings::FlyJoySpeed, 1.f, 20.f);
        AtomicCheckbox("Show Joystick", Settings::bShowJoystick);
    }

    AtomicCheckbox(Localization::Get("disable_cheat"), Settings::Cheatoff);
    AtomicCheckbox(Localization::Get("streamer_mode"), Settings::bStreamerMode);
    AtomicCheckbox(Localization::Get("notifications"), Settings::bEnableNotifications);
}

static void RenderVisualsTab() {
    if (!Settings::bEnableESP.load()) {
        ImGui::TextColored({1.f, 0.8f, 0.2f, 1.f}, "%s", Localization::Get("enable_esp"));
        return;
    }

    AtomicCheckbox(Localization::Get("esp_box"), Settings::bBoxESP);
    AtomicCheckbox(Localization::Get("esp_skeleton"), Settings::bSkeletonESP);
    AtomicCheckbox(Localization::Get("esp_snaplines"), Settings::bLineESP);
    AtomicCheckbox(Localization::Get("esp_minimap"), Settings::bMiniMapEsp);
    AtomicCheckbox(Localization::Get("esp_distance"), Settings::bDistanceESP);
    AtomicCheckbox("ESP Count", Settings::bCountESP);
    AtomicCheckbox(Localization::Get("esp_radius"), Settings::bTurnEspRadius);

    if (Settings::bTurnEspRadius.load()) {
        AtomicSliderFloat("Radius", Settings::espRadiusValue, 50.f, 500.f);
    }

    AtomicSliderFloat("Line Thickness", Settings::lineThickness, 0.5f, 5.f);
}

static void RenderAimbotTab() {
    if (!Settings::bAimEnable.load()) {
        ImGui::TextColored({1.f, 0.8f, 0.2f, 1.f}, "%s", Localization::Get("enable_aimbot"));
        return;
    }

    const char *parts[] = {"Head", "Chest", "Body"};
    int part = Settings::AimPart.load();
    if (ImGui::Combo("Target Part", &part, parts, 3)) {
        Settings::AimPart.store(part);
        Settings::Save();
    }

    AtomicCheckbox("Aimbot Lines", Settings::bAimLine);
    AtomicCheckbox("Aim Indicator", Settings::bAimIndicator);
    AtomicCheckbox("Draw FOV", Settings::bAimDrawFov);
    AtomicCheckbox("Visibility Check", Settings::bVisibilityCheck);
    AtomicCheckbox("Crosshair", Settings::bCrosshair);
    AtomicSliderFloat("FOV", Settings::AimFov, 10.f, 360.f);
    AtomicSliderFloat("Smoothing", Settings::AimSmooth, 1.f, 20.f);
}

static void RenderPlayerTab() {
    AtomicCheckbox("Scale Enable", Settings::ScaleEnable);
    if (Settings::ScaleEnable.load()) {
        AtomicCheckbox("Big Head", Settings::BigHead);
        AtomicCheckbox("Big Chest", Settings::BigChest);
        AtomicCheckbox("Big Body", Settings::BigBody);
        AtomicSliderFloat("Scale Value", Settings::ScaleVal, 1.f, 5.f);
    }
}

static void RenderVehicleTab() {
    AtomicCheckbox("Car Speed Hack", Settings::bCarhack);
    if (Settings::bCarhack.load()) {
        AtomicSliderFloat("Car Speed", Settings::Carspeed, 1.f, 5.f);
    }
    AtomicCheckbox("Car Fly", Settings::bCarFly);
    if (Settings::bCarFly.load()) {
        AtomicSliderFloat("Car Fly Speed", Settings::carFlySpeed, 1.f, 50.f);
    }
}

static void RenderWeaponTab() {
    AtomicCheckbox(Localization::Get("instant_reload"), Settings::bInstantReload);
    AtomicCheckbox("Fast Shoot", Settings::bFastShoot);
}

static void RenderTeleportTab() {
    int count = 0;
    const TeleportLocation *locs = TeleportFeature::GetLocations(count);
    int selected = Settings::selectedTeleport.load();

    ImGui::Text("Teleportation");
    ImGui::Separator();

    for (int i = 0; i < count; i++) {
        if (ImGui::Selectable(locs[i].id, selected == i)) {
            Settings::selectedTeleport.store(i);
            Settings::Save();
        }
    }

    if (ImGui::Button("Teleport Now", {-1, 0})) {
        TeleportFeature::TeleportTo(selected);
    }

    AtomicCheckbox("Auto Teleport", Settings::bAutoTeleport);
}

static void RenderSettingsTab() {
    int theme = Settings::MenuTheme.load();
    if (ImGui::Combo(Localization::Get("menu_theme"), &theme, "Dark Purple\0Ocean Blue\0Blood Red\0Matrix Green\0")) {
        Settings::MenuTheme.store(theme);
        Themes::Apply(theme, ImGui::GetStyle());
        Settings::Save();
    }

    int lang = (int)Localization::GetLanguage();
    if (ImGui::Combo("Language", &lang, "English\0French\0German\0Italian\0Spanish\0")) {
        Localization::SetLanguage(static_cast<Lang>(lang));
    }

    AtomicSliderFloat("UI Scale", Settings::uiScale, 0.75f, 1.5f);
    AtomicSliderInt("Target FPS", Settings::targetFPS, 30, 120);

    ImGui::Separator();
    ImGui::TextColored({0.3f, 1.f, 0.5f, 1.f}, "Loop360 v1.0.7");
    ImGui::Text("Target: OneState Roleplay");
}

void Render(float screenW, float screenH) {
    (void)screenW;
    (void)screenH;

    if (!Settings::bShowMenu.load()) return;

    if (!s_configsLoaded.load()) {
        Settings::Load();
        Themes::Apply(Settings::MenuTheme.load(), ImGui::GetStyle());
        s_configsLoaded.store(true);
    }

    ImGui::SetNextWindowSize({420, 520}, ImGuiCond_FirstUseEver);
    ImGui::Begin("Loop360", nullptr, ImGuiWindowFlags_NoCollapse);

    const char *tabs[] = {
        Localization::Get("tab_general"),
        Localization::Get("tab_visuals"),
        Localization::Get("tab_aimbot"),
        Localization::Get("tab_player"),
        Localization::Get("tab_vehicle"),
        Localization::Get("tab_weapon"),
        Localization::Get("tab_teleport"),
        Localization::Get("tab_settings"),
    };

    int tab = Settings::selectedTab.load();
    if (ImGui::BeginTabBar("MainTabs")) {
        for (int i = 0; i < 8; i++) {
            if (ImGui::BeginTabItem(tabs[i])) {
                if (tab != i) {
                    tab = i;
                    Settings::selectedTab.store(i);
                    Settings::Save();
                }
                switch (i) {
                    case 0: RenderGeneralTab(); break;
                    case 1: RenderVisualsTab(); break;
                    case 2: RenderAimbotTab(); break;
                    case 3: RenderPlayerTab(); break;
                    case 4: RenderVehicleTab(); break;
                    case 5: RenderWeaponTab(); break;
                    case 6: RenderTeleportTab(); break;
                    case 7: RenderSettingsTab(); break;
                }
                ImGui::EndTabItem();
            }
        }
        ImGui::EndTabBar();
    }

    ImGui::End();
}

void RenderOverlay(float screenW, float screenH) {
    if (Settings::Cheatoff.load()) return;

    ImDrawList *draw = ImGui::GetBackgroundDrawList();

    if (Settings::bCrosshair.load()) {
        ImVec2 c(screenW * 0.5f, screenH * 0.5f);
        draw->AddLine({c.x - 12, c.y}, {c.x + 12, c.y}, IM_COL32(0, 255, 100, 200), 1.5f);
        draw->AddLine({c.x, c.y - 12}, {c.x, c.y + 12}, IM_COL32(0, 255, 100, 200), 1.5f);
    }

    if (Settings::bAimEnable.load() && Settings::bAimDrawFov.load()) {
        float fov = Settings::AimFov.load();
        ImVec2 c(screenW * 0.5f, screenH * 0.5f);
        draw->AddCircle(c, fov, IM_COL32(255, 255, 255, 80), 64, 1.5f);
    }
}

} // namespace MenuRenderer
