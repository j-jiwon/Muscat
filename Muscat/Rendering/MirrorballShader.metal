//
//  MirrorballShader.metal
//  Muscat
//
//  Created by Jiwon Jung on 2023/05/07.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


struct FullScreenVertexOut {
    float4 position [[position]];
    float4 clipPosition;
};

vertex FullScreenVertexOut vertex_env(uint index [[vertex_id]]) {
    float2 positions[] = { { -1, 1 }, { -1, -3 }, { 3, 1 } };
    FullScreenVertexOut out;
    out.position = float4(positions[index], 1, 1);
    out.clipPosition = out.position;
    return out;
}

fragment float4 fragment_env(FullScreenVertexOut in [[stage_in]],
                                        constant float4x4 &inverseViewProjectionMatrix [[buffer(0)]],
                                        texturecube<float, access::sample> environmentTexture [[texture(0)]],
                                        sampler cubeSampler [[sampler(0)]])
{
    float4 worldPosition = inverseViewProjectionMatrix * in.clipPosition;
    float3 worldDirection = normalize(worldPosition.xyz);
    return environmentTexture.sample(cubeSampler, worldDirection);
}
