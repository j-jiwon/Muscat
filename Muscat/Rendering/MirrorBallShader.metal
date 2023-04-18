//
//  MirrorBallShader.metal
//  Muscat
//
//  Created by Jiwon Jung on 2023/03/27.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

struct VertexIn {
    float3 position  [[attribute(0)]];
    float3 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 viewPosition;
    float3 normal;
    float2 texCoords;
};

struct InstanceConstants {
    float4x4 modelMatrix;
};

struct FrameConstants {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
    float3x3 inverseViewDirectionMatrix;
    uint lightCount;
    uint renderMode;
};

enum RenderMode: uint {
    RenderModeReflect,
    RenderModeRefract
};

vertex VertexOut vertex_mirrorball(VertexIn in [[stage_in]],
                             constant InstanceConstants *instances [[buffer(2)]],
                             constant FrameConstants &frame [[buffer(3)]],
                             uint instanceID [[instance_id]])
{
    constant InstanceConstants &instance = instances[instanceID];

    float4x4 modelViewMatrix = frame.viewMatrix * instance.modelMatrix;

    float4 worldPosition = instance.modelMatrix * float4(in.position, 1.0);

    float4 viewPosition = frame.viewMatrix * worldPosition;
    float4 viewNormal = modelViewMatrix * float4(in.normal, 0.0);

    VertexOut out;
    out.position = frame.projectionMatrix * viewPosition;
    out.worldPosition = worldPosition.xyz;
    out.viewPosition = viewPosition.xyz;
    out.normal = viewNormal.xyz;
    out.texCoords = in.texCoords;
    return out;
}

fragment float4 fragment_mirrorball(VertexOut in [[stage_in]],
                              constant FrameConstants &frame [[buffer(3)]],
                              texturecube<float, access::sample> environmentTexture [[texture(0)]],
                              sampler cubeSampler [[sampler(0)]])
{
    float4 baseColor = { 0.0, 0.0, 0.0, 1.0 };
    float reflectivity = 1.0;

    float3 N = normalize(in.normal);
    float3 V = normalize(float3(0) - in.viewPosition);

    float3 litColor { 0 };

    float3 R;
    float3 reflection = reflect(-V, N);
    R = frame.inverseViewDirectionMatrix * reflection;

    float3 envColor = environmentTexture.sample(cubeSampler, R).rgb;

    litColor += envColor * reflectivity;

    return float4(litColor * baseColor.a, baseColor.a);
}

struct FullscreenVertexOut {
    float4 position [[position]];
    float4 clipPosition;
};

vertex FullscreenVertexOut vertex_env(uint index [[vertex_id]]) {
    float2 positions[] = { { -1, 1 }, { -1, -3 }, { 3, 1 } };
    FullscreenVertexOut out;
    out.position = float4(positions[index], 1, 1);
    out.clipPosition = out.position;
    return out;
}

fragment float4 fragment_env(FullscreenVertexOut in [[stage_in]],
                                        constant float4x4 &inverseViewProjectionMatrix [[buffer(0)]],
                                        texturecube<float, access::sample> environmentTexture [[texture(0)]],
                                        sampler cubeSampler [[sampler(0)]])
{
    float4 worldPosition = inverseViewProjectionMatrix * in.clipPosition;
    float3 worldDirection = normalize(worldPosition.xyz);
    return environmentTexture.sample(cubeSampler, worldDirection);
}
