#include "Localization.h"
#include "../SSIncludes.h"

namespace Localization {

static Lang g_lang = Lang::EN;

struct Entry {
    const char *en;
    const char *fr;
    const char *de;
    const char *it;
    const char *es;
};

static const std::unordered_map<std::string, Entry> kStrings = {
    {"app_title", {"StateScript", "StateScript", "StateScript", "StateScript", "StateScript"}},
    {"tab_general", {"General", "General", "Allgemein", "Generale", "General"}},
    {"tab_visuals", {"Visuals", "Visuels", "Visuals", "Visuali", "Visuales"}},
    {"tab_aimbot", {"Aimbot", "Aimbot", "Aimbot", "Aimbot", "Aimbot"}},
    {"tab_player", {"Player", "Joueur", "Spieler", "Giocatore", "Jugador"}},
    {"tab_vehicle", {"Vehicle", "Vehicule", "Fahrzeug", "Veicolo", "Vehiculo"}},
    {"tab_weapon", {"Weapon", "Arme", "Waffe", "Arma", "Arma"}},
    {"tab_teleport", {"Teleport", "Teleportation", "Teleportation", "Teletrasporto", "Teletransporte"}},
    {"tab_settings", {"Settings", "Parametres", "Einstellungen", "Impostazioni", "Ajustes"}},
    {"enable_esp", {"Enable ESP", "Activer l'ESP", "ESP aktivieren", "Attiva ESP", "Activar ESP"}},
    {"enable_aimbot", {"Enable Aimbot", "Activer l'Aimbot", "Aimbot aktivieren", "Attiva Aimbot", "Activar Aimbot"}},
    {"esp_box", {"ESP Box", "ESP Box", "ESP Box", "ESP Box", "ESP Box"}},
    {"esp_skeleton", {"ESP Skeleton", "ESP Skeleton", "ESP Skelett", "ESP Skeleton", "ESP Skeleton"}},
    {"esp_snaplines", {"ESP SnapLines", "ESP SnapLines", "ESP Linien", "ESP SnapLines", "ESP SnapLines"}},
    {"esp_minimap", {"ESP Mini Map", "ESP Mini Carte", "ESP Mini-Karte", "ESP Mini Map", "ESP Mini Map"}},
    {"esp_distance", {"ESP Distance", "ESP Distance", "ESP Distanz", "ESP Distance", "ESP Distancia"}},
    {"esp_life", {"ESP Life", "ESP Life", "ESP Life", "ESP Vita", "ESP Vida"}},
    {"esp_vest", {"ESP Vest", "ESP Vest", "ESP Vest", "ESP maglia", "ESP chaleco"}},
    {"esp_radius", {"ESP Distance Limit", "Limite ESP", "ESP Distanzlimit", "Limite ESP", "Limite ESP"}},
    {"speed_hack", {"Speed Hack", "Hack de Vitesse", "Speed Hack", "Speed Hack", "Speed Hack"}},
    {"fly_hacks", {"Fly Hacks", "Fly Hacks", "Fly Hacks", "Fly Hacks", "Fly Hacks"}},
    {"fly_speed", {"Fly Speed", "Fly Speed", "Fly Speed", "Fly Speed", "Fly Speed"}},
    {"instant_reload", {"Instant Reload", "Rechargement Instant", "Sofort Nachladen", "Ricarica Istantanea", "Recarga Instantanea"}},
    {"streamer_mode", {"Streamer Mode", "Mode Streamer", "Streamer Modus", "Modalita Streamer", "Modo Streamer"}},
    {"menu_theme", {"Menu Theme", "Theme Menu", "Menu Theme", "Tema Menu", "Tema Menu"}},
    {"disable_cheat", {"Disable the cheat", "Desactiver le cheat", "Cheat deaktivieren", "Disattiva cheat", "Desactivar cheat"}},
    {"notifications", {"Enable Notifications", "Activer les Notifications", "Benachrichtigungen", "Notifiche", "Notificaciones"}},
    {"cheats_by", {"Cheats by StateScript for OneState Roleplay", "Cheats by StateScript pour OneState", "Cheats by StateScript fur OneState", "Cheats by StateScript per OneState", "Cheats by StateScript para OneState"}},
};

Lang GetLanguage() { return g_lang; }

void SetLanguage(Lang lang) {
    if (lang >= Lang::EN && lang < Lang::Count) g_lang = lang;
}

const char *Get(const char *key) {
    auto it = kStrings.find(key);
    if (it == kStrings.end()) return key;
    const Entry &e = it->second;
    switch (g_lang) {
        case Lang::FR: return e.fr;
        case Lang::DE: return e.de;
        case Lang::IT: return e.it;
        case Lang::ES: return e.es;
        default: return e.en;
    }
}

} // namespace Localization
