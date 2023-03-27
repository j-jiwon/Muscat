//
//  MirrorBallShader.metal
//  Muscat
//
//  Created by Jiwon Jung on 2023/03/27.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;

constant float3 lightPosition = float3(2.0, 1.0, 0);
constant float3 ambientLightColor = float3(1.0, 1.0, 1.0);
constant float ambientLightIntensity = 0.3;
constant float3 lightSpecularColor = float3(1.0, 1.0, 1.0);

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

vertex VertexOut vertex_mirrorball(VertexIn in [[ stage_in ]],
                             constant Uniforms& uniforms [[ buffer(21) ]],
                             constant float &timer [[buffer(2)]]) {
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix * in.position;
    out.worldNormal = (uniforms.modelMatrix * float4(in.normal, 0)).xyz;
    out.worldPosition = (uniforms.modelMatrix * in.position).xyz;
    out.uv = in.uv;
    return out;
}

fragment float4 fragment_mirrorball(VertexOut in [[stage_in]]) {
    float3 lightVector = normalize(lightPosition);
    float3 normalVector = normalize(in.worldNormal);
    
    float3 diffuseIntencity = saturate(dot(lightVector, normalVector));
    
    float3 baseColor = float3(1, 1, 1);
    float3 diffuseColor = baseColor * diffuseIntencity;
    float3 ambientColor = baseColor * ambientLightColor * ambientLightIntensity;
    
    float3 reflection = reflect(lightVector, normalVector);
    
    float3 color = diffuseColor + ambientColor;
    return float4(color.xyz, 1.0f);
}
