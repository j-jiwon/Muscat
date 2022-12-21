//
//  Shaders.metal
//  Muscat
//
//  Created by Jiwon Jung on 2022/12/06.
//

#include <metal_stdlib>
using namespace metal;

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
};

struct VertexOut {
    float4 position [[position]];
    float3 color;
};
 
vertex VertexOut vertex_main(VertexIn vertexBuffer [[stage_in]],
                             constant uint &colorIndex [[buffer(11)]],
                             constant float4x4 &modelMatrix [[buffer(21)]],
                             constant float4x4 &viewMatrix [[buffer(22)]]) {
    VertexOut out {
        .position = viewMatrix * modelMatrix * vertexBuffer.position,  // center (0, 0, 0)
        .color = color[colorIndex],
    };

    return out;
}

fragment float4 fragment_main(VertexOut in  [[stage_in]]) {
    return float4(in.color, 1);  // color 전달 받아서 그려줌
}

