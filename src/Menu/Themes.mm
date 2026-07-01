#include "Themes.h"
#include "imgui.h"

namespace Themes {

static const char *kNames[] = {"Dark Purple", "Ocean Blue", "Blood Red", "Matrix Green"};

int Count() {
    return 4;
}

const char *Name(int themeIndex) {
    if (themeIndex < 0 || themeIndex >= Count()) return kNames[0];
    return kNames[themeIndex];
}

static void ApplyReadableText(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_Text] = {0.96f, 0.96f, 0.98f, 1.f};
    c[ImGuiCol_TextDisabled] = {0.62f, 0.62f, 0.68f, 1.f};
    c[ImGuiCol_Border] = {0.55f, 0.35f, 0.85f, 0.55f};
    c[ImGuiCol_BorderShadow] = {0.f, 0.f, 0.f, 0.f};
    c[ImGuiCol_ChildBg] = {0.12f, 0.10f, 0.16f, 0.92f};
    c[ImGuiCol_PopupBg] = {0.10f, 0.08f, 0.14f, 0.96f};
    c[ImGuiCol_Tab] = {0.18f, 0.12f, 0.28f, 0.90f};
    c[ImGuiCol_TabHovered] = {0.45f, 0.22f, 0.68f, 1.f};
    c[ImGuiCol_TabActive] = {0.52f, 0.24f, 0.78f, 1.f};
    c[ImGuiCol_TitleBg] = {0.14f, 0.08f, 0.22f, 1.f};
    c[ImGuiCol_TitleBgActive] = {0.28f, 0.12f, 0.42f, 1.f};
    c[ImGuiCol_Separator] = {0.55f, 0.35f, 0.85f, 0.45f};
    c[ImGuiCol_ScrollbarBg] = {0.08f, 0.06f, 0.12f, 0.70f};
    c[ImGuiCol_ScrollbarGrab] = {0.45f, 0.22f, 0.68f, 0.85f};
}

static void ApplyDarkPurple(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.11f, 0.09f, 0.15f, 0.97f};
    c[ImGuiCol_Header] = {0.35f, 0.15f, 0.55f, 0.85f};
    c[ImGuiCol_HeaderHovered] = {0.45f, 0.20f, 0.65f, 1.f};
    c[ImGuiCol_HeaderActive] = {0.55f, 0.25f, 0.75f, 1.f};
    c[ImGuiCol_Button] = {0.35f, 0.15f, 0.55f, 0.85f};
    c[ImGuiCol_ButtonHovered] = {0.45f, 0.20f, 0.65f, 1.f};
    c[ImGuiCol_ButtonActive] = {0.55f, 0.25f, 0.75f, 1.f};
    c[ImGuiCol_FrameBg] = {0.18f, 0.12f, 0.26f, 0.90f};
    c[ImGuiCol_FrameBgHovered] = {0.24f, 0.16f, 0.34f, 0.95f};
    c[ImGuiCol_FrameBgActive] = {0.30f, 0.18f, 0.42f, 1.f};
    c[ImGuiCol_CheckMark] = {0.85f, 0.55f, 1.f, 1.f};
    c[ImGuiCol_SliderGrab] = {0.65f, 0.35f, 0.95f, 1.f};
    c[ImGuiCol_SliderGrabActive] = {0.80f, 0.50f, 1.f, 1.f};
}

static void ApplyOceanBlue(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.07f, 0.12f, 0.20f, 0.97f};
    c[ImGuiCol_Header] = {0.10f, 0.35f, 0.65f, 0.85f};
    c[ImGuiCol_Button] = {0.10f, 0.35f, 0.65f, 0.85f};
    c[ImGuiCol_FrameBg] = {0.10f, 0.18f, 0.30f, 0.90f};
    c[ImGuiCol_CheckMark] = {0.40f, 0.78f, 1.f, 1.f};
    c[ImGuiCol_TitleBgActive] = {0.08f, 0.28f, 0.52f, 1.f};
}

static void ApplyBloodRed(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.14f, 0.06f, 0.06f, 0.97f};
    c[ImGuiCol_Header] = {0.55f, 0.10f, 0.10f, 0.85f};
    c[ImGuiCol_Button] = {0.55f, 0.10f, 0.10f, 0.85f};
    c[ImGuiCol_FrameBg] = {0.22f, 0.08f, 0.08f, 0.90f};
    c[ImGuiCol_CheckMark] = {1.f, 0.35f, 0.35f, 1.f};
}

static void ApplyMatrixGreen(ImGuiStyle &s) {
    ImVec4 *c = s.Colors;
    c[ImGuiCol_WindowBg] = {0.06f, 0.14f, 0.08f, 0.97f};
    c[ImGuiCol_Header] = {0.08f, 0.45f, 0.18f, 0.90f};
    c[ImGuiCol_HeaderHovered] = {0.12f, 0.55f, 0.22f, 1.f};
    c[ImGuiCol_HeaderActive] = {0.15f, 0.65f, 0.28f, 1.f};
    c[ImGuiCol_Button] = {0.08f, 0.42f, 0.16f, 0.90f};
    c[ImGuiCol_ButtonHovered] = {0.12f, 0.52f, 0.20f, 1.f};
    c[ImGuiCol_ButtonActive] = {0.15f, 0.62f, 0.25f, 1.f};
    c[ImGuiCol_FrameBg] = {0.08f, 0.20f, 0.12f, 0.92f};
    c[ImGuiCol_CheckMark] = {0.35f, 1.f, 0.50f, 1.f};
    c[ImGuiCol_SliderGrab] = {0.25f, 0.85f, 0.40f, 1.f};
    c[ImGuiCol_TitleBgActive] = {0.06f, 0.35f, 0.14f, 1.f};
    c[ImGuiCol_Tab] = {0.08f, 0.28f, 0.12f, 0.90f};
    c[ImGuiCol_TabHovered] = {0.12f, 0.50f, 0.20f, 1.f};
    c[ImGuiCol_TabActive] = {0.15f, 0.58f, 0.24f, 1.f};
    c[ImGuiCol_Border] = {0.25f, 0.75f, 0.35f, 0.55f};
}

void Apply(int themeIndex, ImGuiStyle &style) {
    ImGui::StyleColorsDark();
    style.WindowRounding = 10.f;
    style.FrameRounding = 6.f;
    style.GrabRounding = 6.f;
    style.ScrollbarRounding = 8.f;
    style.TabRounding = 6.f;
    style.WindowBorderSize = 1.2f;
    style.FrameBorderSize = 1.f;
    style.ItemSpacing = {10.f, 8.f};
    style.WindowPadding = {14.f, 12.f};
    ApplyReadableText(style);
    switch (themeIndex) {
        case 1: ApplyOceanBlue(style); break;
        case 2: ApplyBloodRed(style); break;
        case 3: ApplyMatrixGreen(style); break;
        default: ApplyDarkPurple(style); break;
    }
}

} // namespace Themes
