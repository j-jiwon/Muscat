//
//  Shaders.metal
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/06.
//

#include <metal_stdlib>
using namespace metal;

#include "Common.h"

constant float3 lightPosition = float3(2.0, 1.0, 0);
constant float3 ambientLightColor = float3(1.0, 1.0, 1.0);
constant float ambientIntensity = 0.4f;

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
    float3 lightVector = normalize(lightPosition);
    float3 normalVector = normalize(in.worldNormal);
    float3 diffuseIntensity = saturate(dot(lightVector, normalVector));
    float3 baseColor = in.color;
    
    float3 diffuseColor = baseColor * diffuseIntensity;
    float3 ambientColor = baseColor * ambientLightColor * ambientIntensity;
    
    float3 color = diffuseColor + ambientColor;
    return float4(color, 1);
}
