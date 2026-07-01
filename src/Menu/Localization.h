#pragma once

enum class Lang : int { EN = 0, FR, DE, IT, ES, Count };

namespace Localization {
Lang GetLanguage();
void SetLanguage(Lang lang);
const char *Get(const char *key);
}
