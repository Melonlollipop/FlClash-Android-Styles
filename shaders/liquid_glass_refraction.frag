// Copyright 2025 Kyant
// SPDX-License-Identifier: Apache-2.0
//
// RoundedRectRefractionShaderString from Kyant0/AndroidLiquidGlass 2.0.1
// backdrop/src/commonMain/kotlin/com/kyant/backdrop/internal/Shaders.kt,
// translated from AGSL to GLSL by FlClash for ImageFilter.shader: content
// is a sampler of the backdrop in input pixels, offset is minus the shape's
// origin in them, radiusAt reads the centred coordinate, and depthEffect is
// dropped because LiquidBottomTabs never sets it.

#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 inputSize;
uniform vec2 size;
uniform vec2 offset;
uniform vec4 cornerRadii;
uniform float refractionHeight;
uniform float refractionAmount;
uniform sampler2D content;

out vec4 fragColor;

#include "rounded_rect_sdf.glsl"

vec4 contentAt(vec2 coord) {
  vec2 uv = coord / inputSize;
  // Only engines that still store GLES offscreen targets bottom-up need this.
#if defined(IMPELLER_TARGET_OPENGLES) && !defined(IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED)
  uv.y = 1.0 - uv.y;
#endif
  return texture(content, uv);
}

float circleMap(float x) {
  return 1.0 - sqrt(1.0 - x * x);
}

void main() {
  vec2 coord = FlutterFragCoord().xy;
  vec2 halfSize = size * 0.5;
  vec2 centeredCoord = (coord + offset) - halfSize;
  float radius = radiusAt(centeredCoord, cornerRadii);

  float sd = sdRoundedRect(centeredCoord, halfSize, radius);
  if (-sd >= refractionHeight) {
    fragColor = contentAt(coord);
    return;
  }
  sd = min(sd, 0.0);

  float d = circleMap(1.0 - -sd / refractionHeight) * refractionAmount;
  float gradRadius = min(radius * 1.5, min(halfSize.x, halfSize.y));
  vec2 grad = normalize(gradSdRoundedRect(centeredCoord, halfSize, gradRadius));

  vec2 refractedCoord = coord + d * grad;
  fragColor = contentAt(refractedCoord);
}
