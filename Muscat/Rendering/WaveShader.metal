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
};

vertex VertexOut vertex_wave(VertexIn in [[ stage_in ]],
                               constant Uniforms& uniforms [[ buffer(21) ]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * in.position;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0)).xyz;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    out.uv = in.uv;
        
    return out;
}

fragment float4 fragment_wave(VertexOut in [[stage_in]]) {
    return float4(1, 0, 0, 1);
}
