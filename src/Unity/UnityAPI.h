#pragma once

#include "Vector3.h"
#include <vector>
#include <functional>

namespace UnityAPI {

bool Initialize();
void Shutdown();

void *GetMainCamera();
bool WorldToScreen(const Vector3 &world, Vector2 &screen, float screenW, float screenH);

void Behaviour_SetEnabled(void *behaviour, bool enabled);
void Collider_SetEnabled(void *collider, bool enabled);
void Rigidbody_SetInterpolation(void *rb, int mode);
void Animator_SetApplyRootMotion(void *animator, bool apply);
void Physics_SyncTransforms();

void ScanPlayers(std::vector<PlayerEntity> &outPlayers, const Vector3 &localPos);
void *GetLocalPlayerTransform();
Vector3 GetTransformPosition(void *transform);
void SetTransformPosition(void *transform, const Vector3 &pos);

void ApplySpeedMultiplier(float multiplier);
void ApplyFly(const Vector3 &direction, float speed);
void ApplyCarSpeed(float multiplier);
void ApplyCarFly(float speed);
void ApplyPlayerScale(float head, float chest, float body);
void ApplyInstantReload();
void ApplyFastShoot(bool enabled);

using Il2CppMethod = void (*)();

} // namespace UnityAPI
