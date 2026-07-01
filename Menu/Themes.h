#pragma once

struct ImGuiStyle;

namespace Themes {
void Apply(int themeIndex, ImGuiStyle &style);
const char *Name(int themeIndex);
int Count();
}
