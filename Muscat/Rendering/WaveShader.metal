//
//  WaveShader.metal
//  Muscat
//
//  Created by Jiwon Jung on 2023/02/16.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
    float2 uv;
    float4 color;
};

vertex VertexOut vertex_wave(VertexIn in [[ stage_in ]],
                             constant Uniforms& uniforms [[ buffer(21) ]],
                             constant float &timer [[buffer(2)]]) {
    VertexOut out;
    // center
    float x = abs(0.5f - in.uv.x);
    float y = abs(0.5f - in.uv.y);
    float dist = sqrt(x * x + y * y);
    dist = sin(dist * 50 - timer) * 0.1;
    
    float4 pos = float4(in.position.x, in.position.y - dist, in.position.z, 1.0f);
    
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * pos;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0)).xyz;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    out.uv = in.uv;
    out.color = pos;
    return out;
}

fragment float4 fragment_wave(VertexOut in [[stage_in]]) {
    float val = in.color.y * 3;
    return float4(0.6 + val, 0.5 + val, 1 - (val + 0.5), 1.0);
}
