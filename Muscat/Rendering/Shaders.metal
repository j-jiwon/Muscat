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
constant float ambientLightIntensity = 0.3;
constant float3 lightSpecularColor = float3(1.0, 1.0, 1.0);

constant bool hasColorTextures [[function_constant(0)]];

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
 
vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant Uniforms &uniforms [[buffer(21)]]) {
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * vertexBuffer.position,
        .worldNormal = (uniforms.modelMatrix * float4(vertexBuffer.normal, 0)).xyz,
        .worldPosition = (uniforms.modelMatrix * vertexBuffer.position).xyz,
        .uv = vertexBuffer.uv
    };

    return out;
}

vertex VertexOut vertex_instances(VertexIn vertexBuffer [[stage_in]],
                                  constant Uniforms &uniforms [[buffer(21)]],
                                  constant Instances *instances [[buffer(20)]],
                                  uint instanceID [[instance_id]]) {
    Instances instance = instances[instanceID];
    VertexOut out {
        .position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix *
                    instance.modelMatrix * vertexBuffer.position,
        .worldNormal = (uniforms.modelMatrix * instance.modelMatrix * float4(vertexBuffer.normal, 0)).xyz,
        .worldPosition = (uniforms.modelMatrix * instance.modelMatrix * vertexBuffer.position).xyz,
        .uv = vertexBuffer.uv
    };
    return out;
}

fragment float4 fragment_main(VertexOut in  [[stage_in]],
                              constant Material &material [[buffer(11)]],
                              constant FragmentUniforms &fragmentUniforms [[buffer(22)]],
                              texture2d<float>baseColorTexture [[texture(0),
                                                                function_constant(hasColorTextures)]]){
    
    const sampler s(filter::linear);
    
    float3 lightVector = normalize(lightPosition);
    float3 normalVector = normalize(in.worldNormal);
    float3 materialShininess = material.shininess;
    float3 materialSpecularColor = material.specularColor;
    
    float3 diffuseIntensity = saturate(dot(lightVector, normalVector));
    float3 baseColor;
    if (hasColorTextures){
        baseColor = baseColorTexture.sample(s, in.uv).rgb;
    } else {
        // NOTE : temp
        // baseColor = material.baseColor;
        baseColor = float3(0.5, 0.5, 0.5);
    }
    float3 diffuseColor = baseColor * diffuseIntensity;
    float3 ambientColor = baseColor * ambientLightColor * ambientLightIntensity;
    
    float3 reflection = reflect(lightVector, normalVector);
    float3 cameraVector = normalize(in.worldPosition - fragmentUniforms.cameraPosition);
    float3 specularIntensity = pow(saturate(dot(reflection, cameraVector)), materialShininess);
    float3 specularColor = lightSpecularColor * materialSpecularColor * specularIntensity;
    
    float3 color = diffuseColor + ambientColor + specularColor;
    return float4(color, 1);
}
