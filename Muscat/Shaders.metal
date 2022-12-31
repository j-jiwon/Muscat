//
//  Shaders.metal
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/06.
//

#include <metal_stdlib>
using namespace metal;

#include "Common.h"

constant float3 color[6] = {
    float3(1, 0, 0),
    float3(0, 1, 0),
    float3(0, 0, 1),
    float3(0, 0, 1),
    float3(0, 1, 0),
    float3(1, 0, 1)
};


struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
    float3 worldNormal;
    float3 worldPosition;
};
 
vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant uint &colorIndex [[buffer(11)]],
                             constant Uniforms &uniforms [[buffer(21)]]) {
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexBuffer.position,
        .worldNormal = (uniforms.modelMatrix * float4(vertexBuffer.normal, 0)).xyz,
        .worldPosition = (uniforms.modelMatrix * vertexBuffer.position).xyz,
        .color = color[colorIndex],
    };

    return out;
}

fragment float4 fragment_main(VertexOut in  [[stage_in]]) {
    return float4(normalize(in.worldNormal), 1);  // color 전달 받아서 그려줌
}

