#include "UnityAPI.h"
#include "../SSIncludes.h"

#import <Foundation/Foundation.h>

namespace UnityAPI {

static void *g_unityModule = nullptr;
static std::mutex g_playerMutex;
static std::vector<PlayerEntity> g_cachedPlayers;
static void *g_localTransform = nullptr;

using BehaviourSetEnabledFn = void (*)(void *, bool);
using ColliderSetEnabledFn = void (*)(void *, bool);
using RigidbodySetInterpolationFn = void (*)(void *, int);
using AnimatorApplyRootMotionFn = void (*)(void *, bool);
using SyncTransformsFn = void (*)();

static BehaviourSetEnabledFn Behaviour_set_enabled = nullptr;
static ColliderSetEnabledFn Collider_set_enabled = nullptr;
static RigidbodySetInterpolationFn Rigidbody_set_interpolation = nullptr;
static AnimatorApplyRootMotionFn Animator_set_applyRootMotion = nullptr;
static SyncTransformsFn Physics_SyncTransforms_fn = nullptr;

static void *FindUnityFramework() {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        std::string path(name);
        if (path.find("UnityFramework") != std::string::npos ||
            path.find("oneState") != std::string::npos) {
            return (void *)_dyld_get_image_header(i);
        }
    }
    return dlopen("UnityFramework", RTLD_NOW);
}

static void *ResolveSymbol(const char *pattern) {
    if (!g_unityModule) return nullptr;
    return dlsym(g_unityModule, pattern);
}

bool Initialize() {
    if (g_unityModule) return true;
    g_unityModule = FindUnityFramework();
    if (!g_unityModule) return false;

    Behaviour_set_enabled = (BehaviourSetEnabledFn)ResolveSymbol("UnityEngine.Behaviour::set_enabled");
    Collider_set_enabled = (ColliderSetEnabledFn)ResolveSymbol("UnityEngine.Collider::set_enabled");
    Rigidbody_set_interpolation = (RigidbodySetInterpolationFn)ResolveSymbol("UnityEngine.Rigidbody::set_interpolation");
    Animator_set_applyRootMotion = (AnimatorApplyRootMotionFn)ResolveSymbol("UnityEngine.Animator::set_applyRootMotion");
    Physics_SyncTransforms_fn = (SyncTransformsFn)ResolveSymbol("UnityEngine.Physics::SyncTransforms");

    return true;
}

void Shutdown() {
    g_unityModule = nullptr;
    g_localTransform = nullptr;
    std::lock_guard<std::mutex> lock(g_playerMutex);
    g_cachedPlayers.clear();
}

void Behaviour_SetEnabled(void *behaviour, bool enabled) {
    if (Behaviour_set_enabled && behaviour) Behaviour_set_enabled(behaviour, enabled);
}

void Collider_SetEnabled(void *collider, bool enabled) {
    if (Collider_set_enabled && collider) Collider_set_enabled(collider, enabled);
}

void Rigidbody_SetInterpolation(void *rb, int mode) {
    if (Rigidbody_set_interpolation && rb) Rigidbody_set_interpolation(rb, mode);
}

void Animator_SetApplyRootMotion(void *animator, bool apply) {
    if (Animator_set_applyRootMotion && animator) Animator_set_applyRootMotion(animator, apply);
}

void Physics_SyncTransforms() {
    if (Physics_SyncTransforms_fn) Physics_SyncTransforms_fn();
}

void *GetMainCamera() {
    return nullptr;
}

bool WorldToScreen(const Vector3 &world, Vector2 &screen, float screenW, float screenH) {
    (void)world;
    (void)screen;
    (void)screenW;
    (void)screenH;
    return false;
}

void ScanPlayers(std::vector<PlayerEntity> &outPlayers, const Vector3 &localPos) {
    std::lock_guard<std::mutex> lock(g_playerMutex);
    outPlayers = g_cachedPlayers;
    for (auto &p : outPlayers) {
        p.distance = p.worldPos.distance(localPos);
    }
}

void *GetLocalPlayerTransform() {
    return g_localTransform;
}

Vector3 GetTransformPosition(void *transform) {
    (void)transform;
    return {};
}

void SetTransformPosition(void *transform, const Vector3 &pos) {
    (void)transform;
    (void)pos;
}

void ApplySpeedMultiplier(float multiplier) {
    (void)multiplier;
}

void ApplyFly(const Vector3 &direction, float speed) {
    (void)direction;
    (void)speed;
}

void ApplyCarSpeed(float multiplier) {
    (void)multiplier;
}

void ApplyCarFly(float speed) {
    (void)speed;
}

void ApplyPlayerScale(float head, float chest, float body) {
    (void)head;
    (void)chest;
    (void)body;
}

void ApplyInstantReload() {}

void ApplyFastShoot(bool enabled) {
    (void)enabled;
}

} // namespace UnityAPI
