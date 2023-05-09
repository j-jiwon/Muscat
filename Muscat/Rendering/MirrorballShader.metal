//
//  MirrorballShader.metal
//  Muscat
//
//  Created by Jiwon Jung on 2023/05/07.
//

#include <metal_stdlib>
#include "Common.h"
using namespace metal;


// mirror ball
constant float3 lightPosition = float3(2.0, 1.0, 0);
constant float3 ambientLightColor = float3(1.0, 1.0, 1.0);
constant float ambientLightIntensity = 0.3;
constant float3 lightSpecularColor = float3(1.0, 1.0, 1.0);

constant bool hasColorTextures [[function_constant(0)]];

struct VertexIn {
    float4 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

struct VertexOut1 {
    float4 position [[position]];
    float3 worldNormal;
    float3 worldPosition;
    float2 uv;
};
 
vertex VertexOut1 vertex_mirrorball(VertexIn vertexBuffer [[stage_in]],
                                    constant Uniforms &uniforms [[buffer(21)]],
                                    constant float &timer [[buffer(2)]]) {
    
    
    VertexOut1 out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexBuffer.position,
        .worldNormal = (uniforms.modelMatrix * float4(vertexBuffer.normal, 0)).xyz,
        .worldPosition = (uniforms.modelMatrix * vertexBuffer.position).xyz,
        .uv = vertexBuffer.uv
    };

    return out;
}

fragment float4 fragment_mirrorball(VertexOut1 in  [[stage_in]],
                              constant Material &material [[buffer(11)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(22)]],
                              texture2d<float>baseColorTexture [[texture(0),
                                                                function_constant(hasColorTextures)]],
                                    constant float4x4 &inverseViewProjectionMatrix [[buffer(6)]],
                                    texturecube<float, access::sample> environmentTexture [[texture(3)]],
                                    sampler cubeSampler [[sampler(1)]]){

    float3 lightVector = normalize(lightPosition);
    float3 normalVector = normalize(in.worldNormal);
    float3 materialShininess = material.shininess;
    float3 materialSpecularColor = material.specularColor;
    
    float3 cameraVector = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
    
    float3 diffuseIntensity = saturate(dot(lightVector, normalVector));
    float3 baseColor = {0.5, 0.5, 0.5};
    
    float3 diffuseColor = baseColor * diffuseIntensity;
    float3 ambientColor = baseColor * ambientLightColor * ambientLightIntensity;
    
    float3 reflection = reflect(-lightVector, normalVector);
    
    float3 specularIntensity = pow(saturate(dot(reflection, cameraVector)), materialShininess);


    float3 I = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
    float3 R = reflect(I, normalize(-in.worldNormal));
    float3 R2 = float3(R.z, -R.y, R.x);
    float3 envColor = environmentTexture.sample(cubeSampler, R2).rgb;
    
    float3 specularColor = lightSpecularColor * materialSpecularColor * specularIntensity;

    float3 color = diffuseColor + ambientColor + specularColor + envColor;
    return float4(color, 1);
}


// skybox
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
